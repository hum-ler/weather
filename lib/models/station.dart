import 'package:flutter/material.dart';

import 'package:weather/models/geoposition.dart';

/// A meteorological observing station.
class Station {
  /// The ID of this station.
  String id;

  /// The name of this station.
  String name;

  /// The geographic coordinates of this station.
  Geoposition geoposition;

  /// The time when the readings are last retrieved.
  DateTime timestamp;

  /// The realtime air temperature reading.
  double airTemperature;

  /// The air temperature unit.
  String airTemperatureUnit = '°C';

  /// The realtime rainfall reading.
  double rainfall;

  /// The rainfall unit.
  String rainfallUnit = 'mm';

  /// The realtime relative humidity reading.
  double relativeHumidity;

  /// The relative humidity unit.
  String relativeHumidityUnit = '%';

  /// The realtime wind direction reading.
  int windDirection;

  /// The wind direction unit.
  String windDirectionUnit = '°';

  /// The realtime wind speed reading.
  double windSpeed;

  /// The wind speed unit.
  String windSpeedUnit = 'm/s';

  Station({
    @required this.id,
    @required this.name,
    @required this.geoposition,
  });
}

/// A meteorological observing station that is physically closest to the user.
class NearestStation extends Station {
  /// The geographic coordinates of the user.
  Geoposition userLocation;

  /// The estimated distance from [geoposition] to [userLocation].
  double distance;

  /// The distance unit.
  String distanceUnit = 'km';

  NearestStation({
    @required String id,
    @required String name,
    @required Geoposition geoposition,
  }) : super(id: id, name: name, geoposition: geoposition);
}
