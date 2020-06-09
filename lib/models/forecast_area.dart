import 'package:flutter/material.dart';

import 'package:weather/models/geoposition.dart';

/// A forecast area.
class ForecastArea {
  /// The ID of this forecast area.
  String id;

  /// The name of this forecast area.
  String name;

  /// The geographic coordinates of this forecast area.
  Geoposition geoposition;

  /// The time when the forecast is last retrieved.
  DateTime timestamp;

  /// The 2-hour weather forecast.
  String forecast;

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

  NearestForecastArea({
    @required String id,
    @required String name,
    @required Geoposition geoposition,
  }) : super(id: id, name: name, geoposition: geoposition);
}
