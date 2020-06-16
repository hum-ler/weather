import 'package:flutter/material.dart';

import 'geoposition.dart';

/// A forecast area used for 2-hour forecasts.
class ForecastArea {
  /// The ID of this forecast area.
  String id;

  /// The name of this forecast area.
  String name;

  /// The geographic coordinates of this forecast area.
  Geoposition geoposition;

  /// The time when the forecast is last updated.
  DateTime timestamp;

  /// The 2-hour weather forecast.
  String forecast;

  /// The server timestamp for the 2-hour weather forecast.
  DateTime forecastTimestamp;

  /// Indicates whether the forecast is unexpected.
  ///
  /// For example, an empty string.
  bool forecastAnomaly;

  /// Indicates whether the server timestamp is unexpected.
  ///
  /// For example, not recent enough to be considered realtime.
  bool timestampAnomaly;

  ForecastArea({
    @required this.id,
    @required this.name,
    @required this.geoposition,
  });
}

/// A forecast area that is physically closest to the user.
class NearestForecastArea extends ForecastArea {
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

  NearestForecastArea({
    @required String id,
    @required String name,
    @required Geoposition geoposition,
  }) : super(id: id, name: name, geoposition: geoposition);
}
