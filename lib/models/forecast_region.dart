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
  WindDirection windDirection;

  /// The first 8-hour block in [forecasts].
  ForecastChunk firstForecastChunk;

  /// The start time of the first 8-hour block in [forecasts].
  DateTime firstForecastChunkStartTime;

  /// The collection of forecast for each 8-hour block.
  Map<ForecastChunk, String> forecasts;

  ForecastRegion({
    @required this.id,
    @required this.name,
    @required this.geoposition,
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
  }) : super(id: id, name: name, geoposition: geoposition);
}

/// The general direction of the wind.
enum WindDirection {
  n,
  ne,
  e,
  se,
  s,
  sw,
  w,
  nw,
}

/// A block of 8 hours.
enum ForecastChunk {
  morning,
  afternoon,
  night,
}
