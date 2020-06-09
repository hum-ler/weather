import 'package:flutter/material.dart';

import 'package:weather/services/geolocation.dart';

/// The horizontal geographic coordinates of a point on the map.
class Geoposition {
  /// The latitude of this point.
  final double latitude;

  /// The longitude of this point.
  final double longitude;

  const Geoposition({
    @required this.latitude,
    @required this.longitude,
  });

  /// Gets the approximate distance (in km) from [other].
  double distanceFrom(Geoposition other) {
    return Geolocation.getApproximateDistance(this, other);
  }
}
