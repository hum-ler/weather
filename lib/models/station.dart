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

  /// The server timestamp for the air temperature reading.
  DateTime airTemperatureTimestamp;

  /// The realtime rainfall reading.
  double rainfall;

  /// The rainfall unit.
  String rainfallUnit = 'mm';

  /// The server timestamp for the rainfall reading.
  DateTime rainfallTimestamp;

  /// The realtime relative humidity reading.
  double relativeHumidity;

  /// The relative humidity unit.
  String relativeHumidityUnit = '%';

  /// The server timestamp for the relative humidity reading.
  DateTime relativeHumidityTimestamp;

  /// The realtime wind direction reading.
  int windDirection;

  /// The wind direction unit.
  String windDirectionUnit = '°';

  /// The server timestamp for the wind direction reading.
  DateTime windDirectionTimestamp;

  /// The realtime wind speed reading.
  double windSpeed;

  /// The wind speed unit.
  String windSpeedUnit = 'm/s';

  /// The server timestamp for the wind speed reading.
  DateTime windSpeedTimestamp;

  /// Indicates whether one or more readings are unexpected.
  ///
  /// For example, out of acceptable range.
  bool readingAnomaly;

  /// Indicates whether one or more server timestamps are unexpected.
  ///
  /// For example, not recent enough to be considered realtime.
  bool timestampAnomaly;

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

  /// Indicates whether the distance is unexpected.
  ///
  /// For example, out of acceptable range.
  bool distanceAnomaly;

  NearestStation({
    @required String id,
    @required String name,
    @required Geoposition geoposition,
  }) : super(id: id, name: name, geoposition: geoposition);

  NearestStation.from(NearestStation nearestStation) {
    // Clone everything manually.
    this.airTemperature = nearestStation.airTemperature;
    if (nearestStation.airTemperatureTimestamp != null) {
      this.airTemperatureTimestamp =
          DateTime.parse(nearestStation.airTemperatureTimestamp.toString());
    }
    this.airTemperatureUnit = nearestStation.airTemperatureUnit;
    this.distance = nearestStation.distance;
    this.distanceAnomaly = nearestStation.distanceAnomaly;
    this.distanceUnit = nearestStation.distanceUnit;
    if (nearestStation.geoposition != null) {
      this.geoposition = Geoposition(
        latitude: nearestStation.geoposition.latitude,
        longitude: nearestStation.geoposition.longitude,
      );
    }
    this.id = nearestStation.id;
    this.name = nearestStation.name;
    this.rainfall = nearestStation.rainfall;
    if (nearestStation.rainfallTimestamp != null) {
      this.rainfallTimestamp =
          DateTime.parse(nearestStation.rainfallTimestamp.toString());
    }
    this.rainfallUnit = nearestStation.rainfallUnit;
    this.readingAnomaly = nearestStation.readingAnomaly;
    this.relativeHumidity = nearestStation.relativeHumidity;
    if (nearestStation.relativeHumidityTimestamp != null) {
      this.relativeHumidityTimestamp =
          DateTime.parse(nearestStation.relativeHumidityTimestamp.toString());
    }
    this.relativeHumidityUnit = nearestStation.relativeHumidityUnit;
    if (nearestStation.timestamp != null) {
      this.timestamp = DateTime.parse(nearestStation.timestamp.toString());
    }
    this.timestampAnomaly = nearestStation.timestampAnomaly;
    if (nearestStation.userLocation != null) {
      this.userLocation = Geoposition(
        latitude: nearestStation.userLocation.latitude,
        longitude: nearestStation.userLocation.longitude,
      );
    }
    this.windDirection = nearestStation.windDirection;
    if (nearestStation.windDirectionTimestamp != null) {
      this.windDirectionTimestamp =
          DateTime.parse(nearestStation.windDirectionTimestamp.toString());
    }
    this.windDirectionUnit = nearestStation.windDirectionUnit;
    this.windSpeed = nearestStation.windSpeed;
    if (nearestStation.windSpeedTimestamp != null) {
      this.windSpeedTimestamp =
          DateTime.parse(nearestStation.windSpeedTimestamp.toString());
    }
    this.windSpeedUnit = nearestStation.windSpeedUnit;
  }
}
