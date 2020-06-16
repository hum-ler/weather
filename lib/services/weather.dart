import 'package:flutter/material.dart';

import '../models/forecast_area.dart';
import '../models/forecast_region.dart';
import '../models/geoposition.dart';
import '../models/station.dart';
import '../utils/config.dart' as config;
import '../utils/constants.dart' as constants;
import '../utils/date_time_ext.dart';
import '../utils/http_utils.dart';
import '../utils/math_utils.dart';

/// The weather service.
class Weather {
  // Use a singleton for this service.
  static final Weather _singleton = Weather._weather();

  Weather._weather();

  factory Weather() => _singleton;

  /// The collection of [NearestStation]s.
  ///
  /// Uses [Station.id] as the key.
  ///
  /// Using type [NearestStation] instead of [Station] as a convenience
  /// for findNearest... methods.
  Map<String, NearestStation> _stations;

  /// The collection of [NearestForecastArea]s.
  ///
  /// Uses [ForecastArea.id] as the key.
  ///
  /// Using type [NearestForecastArea] instead of [ForecastArea] as a
  /// convenience for [findNearest2HourForecast()].
  Map<String, NearestForecastArea> _forecastAreas;

  /// The collection of [NearestForecastRegion]s.
  ///
  /// Uses [ForecastRegion.id] as the key.
  ///
  /// Using type [NearestForecastRegion] instead of [ForecastRegion] as a
  /// convenience for [findNearest24HourForecast()].
  Map<String, NearestForecastRegion> _forecastRegions;

  /// The time when [fetchReadings()] is last called.
  DateTime _timestamp;

  /// Retrieves all the [Station]s and their corresponding readings.
  Future<void> fetchReadings({DateTime timestamp}) async {
    timestamp ??= DateTime.now();

    // Preform a fetch only if we are over the minimum period.
    if (_timestamp != null &&
        _timestamp.difference(timestamp).abs() < config.minFetchPeriod) {
      return;
    }

    _stations = <String, NearestStation>{};
    _forecastAreas = <String, NearestForecastArea>{};
    _forecastRegions = <String, NearestForecastRegion>{};

    await _fetchAirTemperature(timestamp: timestamp);
    await _fetchRainfall(timestamp: timestamp);
    await _fetchRelativeHumidity(timestamp: timestamp);
    await _fetchWindDirection(timestamp: timestamp);
    await _fetchWindSpeed(timestamp: timestamp);

    await _fetch2HourWeatherForecasts(
      timestamp: timestamp,
      url: constants.forecast2HourUrl,
    );
    await _fetch24HourWeatherForecasts(
      timestamp: timestamp,
      url: constants.forecast24HourUrl,
    );

    _timestamp = timestamp;
  }

  /// Gets the nearest station with air temperature reading.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestAirTemperature(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.airTemperature,
    );

    return _updateAirTemperatureAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest station with rainfall reading.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestRainfall(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.rainfall,
    );

    return _updateRainfallAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest station with relative humidity reading.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestRelativeHumidity(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.relativeHumidity,
    );

    return _updateRelativeHumidityAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest station with wind direction / wind speed readings.
  ///
  /// Call [fetchReadings()] before this.
  NearestStation nearestWindDirectionWindSpeed(Geoposition geoposition) {
    NearestStation s = _deduceNearestStation(
      geoposition,
      WeatherReadingType.windSpeed,
    );

    return _updateWindDirectionWindSpeedAnomalies(NearestStation.from(s));
  }

  /// Gets the nearest forecast area with forecast data.
  ///
  /// Call [fetchReadings()] before this.
  NearestForecastArea nearest2HourForecast(Geoposition geoposition) {
    NearestForecastArea f =
        _forecastAreas.values.where((e) => e.forecast != null).map((e) {
      e.userLocation = geoposition;
      e.distance = e.geoposition.distanceFrom(geoposition);
      return e;
    }).reduce((v, e) => v.distance < e.distance ? v : e);

    return _update2HourForecastAnomalies(f);
  }

  NearestForecastRegion nearest24HourForecast(Geoposition geoposition) {
    NearestForecastRegion f = _forecastRegions.values
        .where((e) => e.overallForecast != null)
        .map((e) {
      e.userLocation = geoposition;
      e.distance = e.geoposition.distanceFrom(geoposition);
      return e;
    }).reduce((v, e) => v.distance < e.distance ? v : e);

    return _update24HourForecastAnomalies(f);
  }

  /// Picks the nearest station out of [_stations] for reading [type].
  ///
  /// Updates [NearestStation.userLocation] and [NearestStation.distance]
  /// in the element as a side-effect.
  NearestStation _deduceNearestStation(
    Geoposition geoposition,
    WeatherReadingType type,
  ) {
    if (geoposition == null) return null;

    Iterable<NearestStation> relevantStations;

    switch (type) {
      case WeatherReadingType.airTemperature:
        relevantStations =
            _stations.values.where((e) => e.airTemperature != null);
        break;

      case WeatherReadingType.rainfall:
        relevantStations = _stations.values.where((e) => e.rainfall != null);
        break;

      case WeatherReadingType.relativeHumidity:
        relevantStations =
            _stations.values.where((e) => e.relativeHumidity != null);
        break;

      case WeatherReadingType.windDirection:
      case WeatherReadingType.windSpeed:
        relevantStations = _stations.values
            .where((e) => e.windDirection != null && e.windSpeed != null);
        break;
    }

    if (relevantStations.length == 0) return null;

    return relevantStations.map((e) {
      e.userLocation = geoposition;
      e.distance = e.geoposition.distanceFrom(geoposition);
      return e;
    }).reduce((v, e) => v.distance < e.distance ? v : e);
  }

  /// Fetches actual data using the realtime weather readings API.
  ///
  /// The data structure returned by the API is the same for the different
  /// reading types.
  ///
  /// Updates [_stations].
  Future<void> _fetchRealtimeWeatherReadings({
    @required DateTime timestamp,
    @required String url,
    @required WeatherReadingType type,
  }) async {
    if (timestamp == null) return;

    String fullUrl =
        '$url?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return;

    if (data['api_info']['status'] == 'healthy') {
      // Generate the list of all stations from the metadata.
      Map<String, NearestStation> potentialStations =
          <String, NearestStation>{};

      (data['metadata']['stations'] as List).forEach((element) {
        if (!potentialStations.containsKey(element['id'])) {
          potentialStations[element['id']] = NearestStation(
            id: element['id'],
            name: element['name'],
            geoposition: Geoposition(
              latitude: element['location']['latitude'],
              longitude: element['location']['longitude'],
            ),
          );
        }
      });

      DateTime serverTimestamp =
          DateTime.tryParse(data['items'][0]['timestamp']);

      (data['items'][0]['readings'] as List).forEach((element) {
        NearestStation station;

        // Look for an existing station in [_stations] first. Otherwise, copy
        // over the new one from [potentialStations].
        if (_stations.containsKey(element['station_id'])) {
          station = _stations[element['station_id']];
        } else if (potentialStations.containsKey(element['station_id'])) {
          station = potentialStations[element['station_id']];
          _stations[station.id] = station;
        }

        if (station != null) {
          // The value may be returned with or without a decimal point, so a
          // conversion is needed.
          double value = (element['value'] as num).toDouble();

          switch (type) {
            case WeatherReadingType.airTemperature:
              station.airTemperature = value;
              station.airTemperatureTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.rainfall:
              station.rainfall = value;
              station.rainfallTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.relativeHumidity:
              station.relativeHumidity = value;
              station.relativeHumidityTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.windDirection:
              station.windDirection = value.toInt();
              station.windDirectionTimestamp = serverTimestamp;
              break;

            case WeatherReadingType.windSpeed:
              station.windSpeed = knotsToMetersPerSecond(value);
              station.windSpeedTimestamp = serverTimestamp;
              break;
          }

          station.timestamp = timestamp;
        }
      });
    }
  }

  Future<void> _fetchAirTemperature({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.airTemperatureUrl,
      type: WeatherReadingType.airTemperature,
    );
  }

  Future<void> _fetchRainfall({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.rainfallUrl,
      type: WeatherReadingType.rainfall,
    );
  }

  Future<void> _fetchRelativeHumidity({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.relativeHumidityUrl,
      type: WeatherReadingType.relativeHumidity,
    );
  }

  Future<void> _fetchWindDirection({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
        timestamp: timestamp,
        url: constants.windDirectionUrl,
        type: WeatherReadingType.windDirection);
  }

  Future<void> _fetchWindSpeed({@required DateTime timestamp}) {
    return _fetchRealtimeWeatherReadings(
        timestamp: timestamp,
        url: constants.windSpeedUrl,
        type: WeatherReadingType.windSpeed);
  }

  /// Fetches actual data using the 2-hour weather forecast API.
  ///
  /// Updates [_forecastAreas].
  Future<void> _fetch2HourWeatherForecasts({
    @required DateTime timestamp,
    @required String url,
  }) async {
    if (timestamp == null) return;

    String fullUrl =
        '$url?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return;

    if (data['api_info']['status'] == 'healthy') {
      // Generate the list of all areas from the metadata.
      Map<String, NearestForecastArea> potentialForecastAreas =
          <String, NearestForecastArea>{};

      (data['area_metadata'] as List).forEach((element) {
        if (!potentialForecastAreas.containsKey(element['name'])) {
          potentialForecastAreas[element['name']] = NearestForecastArea(
            id: element['name'],
            name: element['name'],
            geoposition: Geoposition(
              latitude: element['label_location']['latitude'],
              longitude: element['label_location']['longitude'],
            ),
          );
        }
      });

      DateTime serverTimestamp =
          DateTime.tryParse(data['items'][0]['timestamp']);

      (data['items'][0]['forecasts'] as List).forEach((element) {
        NearestForecastArea forecastArea;

        if (potentialForecastAreas.containsKey(element['area'])) {
          forecastArea = potentialForecastAreas[element['area']];
          _forecastAreas[forecastArea.id] = forecastArea;
        }

        if (forecastArea != null) {
          forecastArea.forecast = element['forecast'];
          forecastArea.forecastTimestamp = serverTimestamp;
          forecastArea.timestamp = timestamp;
        }
      });
    }
  }

  /// Fetches actual data using the 24-hour weather forecast API.
  ///
  /// Updates [_forecastRegions].
  Future<void> _fetch24HourWeatherForecasts({
    @required DateTime timestamp,
    @required String url,
  }) async {
    if (timestamp == null) return;

    String fullUrl =
        '$url?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return;

    List<String> supportedRegions = <String>[
      'central',
      'north',
      'east',
      'south',
      'west',
    ];

    if (data['api_info']['status'] == 'healthy') {
      // Gather the common details across regions.
      DateTime serverTimestamp =
          DateTime.tryParse(data['items'][0]['timestamp']);
      String overallForecast = data['items'][0]['general']['forecast'];
      int minAirTemperature = data['items'][0]['general']['temperature']['low'];
      int maxAirTemperature =
          data['items'][0]['general']['temperature']['high'];
      int minRelativeHumidity =
          data['items'][0]['general']['relative_humidity']['low'];
      int maxRelativeHumidity =
          data['items'][0]['general']['relative_humidity']['high'];
      int minWindSpeed = knotsToMetersPerSecond(
              data['items'][0]['general']['wind']['speed']['low'])
          .round();
      int maxWindSpeed = knotsToMetersPerSecond(
              data['items'][0]['general']['wind']['speed']['high'])
          .round();
      String windDirection = data['items'][0]['general']['wind']['direction'];

      // Prepare a fresh object for each region and fill in the common details.
      supportedRegions.forEach((element) {
        _forecastRegions[element] = NearestForecastRegion(
          id: element,
          name: element,
          geoposition: _getPositionFromRegionName(element),
          timestamp: serverTimestamp,
          overallForecast: overallForecast,
          minAirTemperature: minAirTemperature,
          maxAirTemperature: maxAirTemperature,
          minRelativeHumidity: minRelativeHumidity,
          maxRelativeHumidity: maxRelativeHumidity,
          minWindSpeed: minWindSpeed,
          maxWindSpeed: maxWindSpeed,
          windDirection: windDirection,
        );
      });

      (data['items'][0]['periods'] as List).asMap().forEach((index, element) {
        DateTime forecastChunkStartTime =
            DateTime.parse(element['time']['start']);

        ForecastChunk forecastChunk;
        switch (forecastChunkStartTime.toLocal().hour) {
          case 0:
            forecastChunk = ForecastChunk.predawn;
            break;

          case 6:
            forecastChunk = ForecastChunk.morning;
            break;

          case 12:
            forecastChunk = ForecastChunk.afternoon;
            break;

          case 18:
            forecastChunk = ForecastChunk.night;
            break;
        }

        if (forecastChunk != null) {
          supportedRegions.forEach((region) {
            _forecastRegions[region].forecasts ??= <ForecastChunk, String>{};

            _forecastRegions[region].forecasts[forecastChunk] =
                element['regions'][region];

            if (index == 0) {
              _forecastRegions[region]
                ..firstForecastChunk = forecastChunk
                ..firstForecastChunkStartTime = forecastChunkStartTime;

              switch (forecastChunk) {
                case ForecastChunk.predawn:
                  _forecastRegions[region].forecastOrder = <ForecastChunk>[
                    ForecastChunk.predawn,
                    ForecastChunk.morning,
                    ForecastChunk.afternoon,
                    ForecastChunk.night,
                  ];
                  break;

                case ForecastChunk.morning:
                  _forecastRegions[region].forecastOrder = <ForecastChunk>[
                    ForecastChunk.morning,
                    ForecastChunk.afternoon,
                    ForecastChunk.night,
                  ];
                  break;

                case ForecastChunk.afternoon:
                  _forecastRegions[region].forecastOrder = <ForecastChunk>[
                    ForecastChunk.afternoon,
                    ForecastChunk.night,
                    ForecastChunk.morning,
                  ];
                  break;

                case ForecastChunk.night:
                  _forecastRegions[region].forecastOrder = <ForecastChunk>[
                    ForecastChunk.night,
                    ForecastChunk.morning,
                    ForecastChunk.afternoon,
                  ];
                  break;
              }
            }
          });
        }
      });
    }
  }

  /// Gets the reference [Geoposition] for the region with [regionName].
  Geoposition _getPositionFromRegionName(String regionName) {
    switch (regionName) {
      case 'central':
        return constants.centralRegion;

      case 'north':
        return constants.northRegion;

      case 'east':
        return constants.eastRegion;

      case 'south':
        return constants.southRegion;

      case 'west':
        return constants.westRegion;

      default:
        return null;
    }
  }

  NearestStation _updateAirTemperatureAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly =
          s.airTemperatureTimestamp.difference(_timestamp).abs() >
              config.maxReadingRecency;
      s.distanceAnomaly = s.distance > config.maxDistance;
    }

    return s;
  }

  NearestStation _updateRainfallAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly = s.rainfallTimestamp.difference(_timestamp).abs() >
          config.maxReadingRecency;
      s.distanceAnomaly = s.distance > config.maxDistance;
    }

    return s;
  }

  NearestStation _updateRelativeHumidityAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly =
          s.relativeHumidityTimestamp.difference(_timestamp).abs() >
              config.maxReadingRecency;
      s.distanceAnomaly = s.distance > config.maxDistance;
    }

    return s;
  }

  NearestStation _updateWindDirectionWindSpeedAnomalies(NearestStation s) {
    if (s != null) {
      s.readingAnomaly = false;
      s.timestampAnomaly = s.windSpeedTimestamp.difference(_timestamp).abs() >
          config.maxReadingRecency;
      s.distanceAnomaly = s.distance > config.maxDistance;
    }

    return s;
  }

  NearestForecastArea _update2HourForecastAnomalies(NearestForecastArea f) {
    if (f != null) {
      f.forecastAnomaly = f.forecast == null || f.forecast.isEmpty;
      f.timestampAnomaly = f.forecastTimestamp.difference(_timestamp).abs() >
          config.maxReadingRecency;
      f.distanceAnomaly = f.distance > config.maxDistance;
    }

    return f;
  }

  NearestForecastRegion _update24HourForecastAnomalies(
      NearestForecastRegion f) {
    if (f != null) {
      f.forecastAnomaly = f.overallForecast == null ||
          f.overallForecast.isEmpty ||
          (f.forecasts.length != 3 && f.forecasts.length != 4);
      f.timestampAnomaly = f.timestamp.difference(_timestamp).abs() >
          config.max24HourForecastRecency;
      f.distanceAnomaly = f.distance > config.maxRegionDistance;
    }

    return f;
  }
}

enum WeatherReadingType {
  airTemperature,
  rainfall,
  relativeHumidity,
  windDirection,
  windSpeed,
}
