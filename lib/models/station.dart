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

  /// The time when the readings are last updated.
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

  factory NearestStation.from(NearestStation nearestStation) {
    if (nearestStation == null) return null;

    NearestStation s = NearestStation(
      id: nearestStation.id,
      name: nearestStation.name,
      geoposition: nearestStation.geoposition != null
          ? Geoposition(
              latitude: nearestStation.geoposition.latitude,
              longitude: nearestStation.geoposition.longitude,
            )
          : null,
    );

    // Clone everything manually.
    s.airTemperature = nearestStation.airTemperature;
    if (nearestStation.airTemperatureTimestamp != null) {
      s.airTemperatureTimestamp =
          DateTime.parse(nearestStation.airTemperatureTimestamp.toString());
    }
    s.airTemperatureUnit = nearestStation.airTemperatureUnit;
    s.distance = nearestStation.distance;
    s.distanceAnomaly = nearestStation.distanceAnomaly;
    s.distanceUnit = nearestStation.distanceUnit;
    s.rainfall = nearestStation.rainfall;
    if (nearestStation.rainfallTimestamp != null) {
      s.rainfallTimestamp =
          DateTime.parse(nearestStation.rainfallTimestamp.toString());
    }
    s.rainfallUnit = nearestStation.rainfallUnit;
    s.readingAnomaly = nearestStation.readingAnomaly;
    s.relativeHumidity = nearestStation.relativeHumidity;
    if (nearestStation.relativeHumidityTimestamp != null) {
      s.relativeHumidityTimestamp =
          DateTime.parse(nearestStation.relativeHumidityTimestamp.toString());
    }
    s.relativeHumidityUnit = nearestStation.relativeHumidityUnit;
    if (nearestStation.timestamp != null) {
      s.timestamp = DateTime.parse(nearestStation.timestamp.toString());
    }
    s.timestampAnomaly = nearestStation.timestampAnomaly;
    if (nearestStation.userLocation != null) {
      s.userLocation = Geoposition(
        latitude: nearestStation.userLocation.latitude,
        longitude: nearestStation.userLocation.longitude,
      );
    }
    s.windDirection = nearestStation.windDirection;
    if (nearestStation.windDirectionTimestamp != null) {
      s.windDirectionTimestamp =
          DateTime.parse(nearestStation.windDirectionTimestamp.toString());
    }
    s.windDirectionUnit = nearestStation.windDirectionUnit;
    s.windSpeed = nearestStation.windSpeed;
    if (nearestStation.windSpeedTimestamp != null) {
      s.windSpeedTimestamp =
          DateTime.parse(nearestStation.windSpeedTimestamp.toString());
    }
    s.windSpeedUnit = nearestStation.windSpeedUnit;

    return s;
  }
}
