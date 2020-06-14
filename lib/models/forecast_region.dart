import 'package:flutter/material.dart';

import 'package:weather/models/geoposition.dart';

/// A forecast region used for 24-hour forecasts.
class ForecastRegion {
  /// The ID of this region.
  String id;

  /// The name of this region.
  String name;

  /// The geographic coordinates of this forecast region.
  Geoposition geoposition;

  /// The time when the forecast is last updated.
  DateTime timestamp;

  /// The overall forecast for the next 24 hours.
  String overallForecast;

  /// The minimum air temperature for the next 24 hours.
  int minAirTemperature;

  /// The maximum air temperature for the next 24 hours.
  int maxAirTemperature;

  /// The air temperature unit.
  String airTemperatureUnit = '°C';

  /// The minimum relative humidity for the next 24 hours.
  int minRelativeHumidity;

  /// The maximum relative humidity for the next 24 hours.
  int maxRelativeHumidity;

  /// The relative humidity unit.
  String relativeHumidityUnit = '%';

  /// The minimum wind speed for the next 24 hours.
  int minWindSpeed;

  /// The maximum wind speed for the next 24 hours.
  int maxWindSpeed;

  /// The wind speed unit.
  String windSpeedUnit = 'm/s';

  /// The general wind direction for the next 24 hours.
  String windDirection;

  /// The first block in [forecasts].
  ForecastChunk firstForecastChunk;

  /// The start time of the first block in [forecasts].
  DateTime firstForecastChunkStartTime;

  /// The chronological order for the blocks in [forecasts].
  List<ForecastChunk> forecastOrder;

  /// The collection of forecasts for each block.
  Map<ForecastChunk, String> forecasts;

  /// Indicates whether any of the forecasts is unexpected.
  ///
  /// For example, an empty string.
  bool forecastAnomaly;

  /// Indicates whether the server timestamp is unexpected.
  ///
  /// For example, not recent enough to be considered realtime.
  bool timestampAnomaly;

  ForecastRegion({
    @required this.id,
    @required this.name,
    @required this.geoposition,
    this.timestamp,
    this.overallForecast,
    this.minAirTemperature,
    this.maxAirTemperature,
    this.airTemperatureUnit = '°C',
    this.minRelativeHumidity,
    this.maxRelativeHumidity,
    this.relativeHumidityUnit = '%',
    this.minWindSpeed,
    this.maxWindSpeed,
    this.windSpeedUnit = 'm/s',
    this.windDirection,
  });
}

class NearestForecastRegion extends ForecastRegion {
  /// The geographic coordinates of the user.
  Geoposition userLocation;

  /// The estimated distance from [geoposition] to [userLocation].
  double distance;

  /// The distance unit.
  String distanceUnit = 'km';

  /// Indicates whether the distance is unexpected.
  ///
  /// For example, out of acceptable range.
  bool distanceAnomaly;

  NearestForecastRegion({
    @required String id,
    @required String name,
    @required Geoposition geoposition,
    DateTime timestamp,
    String overallForecast,
    int minAirTemperature,
    int maxAirTemperature,
    String airTemperatureUnit = '°C',
    int minRelativeHumidity,
    int maxRelativeHumidity,
    String relativeHumidityUnit = '%',
    int minWindSpeed,
    int maxWindSpeed,
    String windSpeedUnit = 'm/s',
    String windDirection,
  }) : super(
          id: id,
          name: name,
          geoposition: geoposition,
          timestamp: timestamp,
          overallForecast: overallForecast,
          minAirTemperature: minAirTemperature,
          maxAirTemperature: maxAirTemperature,
          airTemperatureUnit: airTemperatureUnit,
          minRelativeHumidity: minRelativeHumidity,
          maxRelativeHumidity: maxRelativeHumidity,
          relativeHumidityUnit: relativeHumidityUnit,
          minWindSpeed: minWindSpeed,
          maxWindSpeed: maxWindSpeed,
          windSpeedUnit: windSpeedUnit,
          windDirection: windDirection,
        );
}

/// A block of time for which a forecast is available.
///
/// The length of each blocks is different:
/// - morning -- 6 hours (typically 6AM to 12PM)
/// - afternoon -- 6 hours (typically 12PM to 6PM)
/// - night -- 12 hours (typically from 6PM tp 6AM)
enum ForecastChunk {
  morning,
  afternoon,
  night,
}
