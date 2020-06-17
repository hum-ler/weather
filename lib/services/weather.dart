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

    List<dynamic> resultsList = await Future.wait([
      _fetchAirTemperature(timestamp: timestamp),
      _fetchRainfall(timestamp: timestamp),
      _fetchRelativeHumidity(timestamp: timestamp),
      _fetchWindDirection(timestamp: timestamp),
      _fetchWindSpeed(timestamp: timestamp),
      _fetch2HourWeatherForecasts(timestamp: timestamp),
      _fetch24HourWeatherForecasts(timestamp: timestamp),
    ]);
    _processFetchResults(resultsList);

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
  Future<Map<String, NearestStation>> _fetchRealtimeWeatherReadings({
    @required DateTime timestamp,
    @required String url,
    @required WeatherReadingType type,
  }) async {
    if (timestamp == null) return null;

    String fullUrl =
        '$url?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return null;

    Map<String, NearestStation> stations = <String, NearestStation>{};

    if (data['api_info']['status'] == 'healthy') {
      // Generate the collection of all stations from the metadata.
      (data['metadata']['stations'] as List).forEach((element) {
        if (!stations.containsKey(element['id'])) {
          stations[element['id']] = NearestStation(
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

      // Fill in the readings.
      (data['items'][0]['readings'] as List).forEach((element) {
        NearestStation station;
        if (stations.containsKey(element['station_id'])) {
          station = stations[element['station_id']];
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

    return stations;
  }

  Future<Map<String, NearestStation>> _fetchAirTemperature({
    @required DateTime timestamp,
  }) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.airTemperatureUrl,
      type: WeatherReadingType.airTemperature,
    );
  }

  Future<Map<String, NearestStation>> _fetchRainfall({
    @required DateTime timestamp,
  }) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.rainfallUrl,
      type: WeatherReadingType.rainfall,
    );
  }

  Future<Map<String, NearestStation>> _fetchRelativeHumidity({
    @required DateTime timestamp,
  }) {
    return _fetchRealtimeWeatherReadings(
      timestamp: timestamp,
      url: constants.relativeHumidityUrl,
      type: WeatherReadingType.relativeHumidity,
    );
  }

  Future<Map<String, NearestStation>> _fetchWindDirection({
    @required DateTime timestamp,
  }) {
    return _fetchRealtimeWeatherReadings(
        timestamp: timestamp,
        url: constants.windDirectionUrl,
        type: WeatherReadingType.windDirection);
  }

  Future<Map<String, NearestStation>> _fetchWindSpeed({
    @required DateTime timestamp,
  }) {
    return _fetchRealtimeWeatherReadings(
        timestamp: timestamp,
        url: constants.windSpeedUrl,
        type: WeatherReadingType.windSpeed);
  }

  /// Fetches actual data using the 2-hour weather forecast API.
  Future<Map<String, NearestForecastArea>> _fetch2HourWeatherForecasts({
    @required DateTime timestamp,
  }) async {
    if (timestamp == null) return null;

    String fullUrl =
        '${constants.forecast2HourUrl}?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return null;

    Map<String, NearestForecastArea> forecastAreas =
        <String, NearestForecastArea>{};

    if (data['api_info']['status'] == 'healthy') {
      // Generate the collection of all areas from the metadata.
      (data['area_metadata'] as List).forEach((element) {
        if (!forecastAreas.containsKey(element['name'])) {
          forecastAreas[element['name']] = NearestForecastArea(
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

      // Fill in the forecasts.
      (data['items'][0]['forecasts'] as List).forEach((element) {
        NearestForecastArea forecastArea;
        if (forecastAreas.containsKey(element['area'])) {
          forecastArea = forecastAreas[element['area']];
        }
        if (forecastArea != null) {
          forecastArea.forecast = element['forecast'];
          forecastArea.forecastTimestamp = serverTimestamp;
          forecastArea.timestamp = timestamp;
        }
      });
    }

    return forecastAreas;
  }

  /// Fetches actual data using the 24-hour weather forecast API.
  Future<Map<String, NearestForecastRegion>> _fetch24HourWeatherForecasts({
    @required DateTime timestamp,
  }) async {
    if (timestamp == null) return null;

    String fullUrl =
        '${constants.forecast24HourUrl}?date_time=${timestamp.toLocal().format("yyyy-MM-ddTHH:mm:ss")}';

    dynamic data = await httpGetJsonData(fullUrl);
    if (data == null) return null;

    List<String> supportedRegions = <String>[
      'central',
      'north',
      'east',
      'south',
      'west',
    ];

    Map<String, NearestForecastRegion> forecastRegions =
        <String, NearestForecastRegion>{};

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
        forecastRegions[element] = NearestForecastRegion(
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

      // Fill in the forecast for each chunk.
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
            forecastRegions[region].forecasts ??= <ForecastChunk, String>{};

            forecastRegions[region].forecasts[forecastChunk] =
                element['regions'][region];

            if (index == 0) {
              forecastRegions[region]
                ..firstForecastChunk = forecastChunk
                ..firstForecastChunkStartTime = forecastChunkStartTime;

              switch (forecastChunk) {
                case ForecastChunk.predawn:
                  forecastRegions[region].forecastOrder = <ForecastChunk>[
                    ForecastChunk.predawn,
                    ForecastChunk.morning,
                    ForecastChunk.afternoon,
                    ForecastChunk.night,
                  ];
                  break;

                case ForecastChunk.morning:
                  forecastRegions[region].forecastOrder = <ForecastChunk>[
                    ForecastChunk.morning,
                    ForecastChunk.afternoon,
                    ForecastChunk.night,
                  ];
                  break;

                case ForecastChunk.afternoon:
                  forecastRegions[region].forecastOrder = <ForecastChunk>[
                    ForecastChunk.afternoon,
                    ForecastChunk.night,
                    ForecastChunk.morning,
                  ];
                  break;

                case ForecastChunk.night:
                  forecastRegions[region].forecastOrder = <ForecastChunk>[
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

    return forecastRegions;
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

  /// Handles the results coming from parallel API calls.
  ///
  /// Modifies [_stations], [_forecastAreas] and [_forecastRegions] directly.
  ///
  /// See [fetchReadings()] (specifically the call to [Future.wait()]) to find
  /// out the order of the results.
  void _processFetchResults(List<dynamic> resultsList) {
    resultsList.asMap().forEach((index, element) {
      // Handle readings.
      if (index < 5) {
        if (element != null && element is Map<String, NearestStation>) {
          // Merge all the stations together.
          element.forEach((key, value) {
            if (_stations.containsKey(key)) {
              _stations[key].merge(value);
            } else {
              _stations[key] = value;
            }
          });
        }
      }

      // Handle 2-hour forecasts.
      if (index == 5) {
        if (element != null && element is Map<String, NearestForecastArea>) {
          _forecastAreas = element;
        }
      }

      // Handle 24-hour forecasts.
      if (index == 6) {
        if (element != null && element is Map<String, NearestForecastRegion>) {
          _forecastRegions = element;
        }
      }
    });
  }
}

enum WeatherReadingType {
  airTemperature,
  rainfall,
  relativeHumidity,
  windDirection,
  windSpeed,
}
