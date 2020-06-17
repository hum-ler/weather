import 'dart:math';

import 'package:flutter/foundation.dart';

import '../utils/math_utils.dart';

/// The horizontal geographic coordinates of a point on the map.
@immutable
class Geoposition {
  /// The latitude of this point.
  final double latitude;

  /// The longitude of this point.
  final double longitude;

  const Geoposition({
    @required this.latitude,
    @required this.longitude,
  })  : assert(latitude != null),
        assert(longitude != null);

  /// Gets the approximate distance (in km) from [other].
  double distanceFrom(Geoposition other) {
    return getApproximateDistance(this, other);
  }

  /// Calculates the approximate distance (in km) between 2 [Geoposition]s.
  ///
  /// Uses the haversine formula, see https://en.wikipedia.org/wiki/Haversine_formula.
  static double getApproximateDistance(Geoposition p1, Geoposition p2) {
    // Convert all coordinates to radians first.
    double phi1 = degreesToRadians(p1.latitude);
    double phi2 = degreesToRadians(p2.latitude);
    double lambda1 = degreesToRadians(p1.longitude);
    double lambda2 = degreesToRadians(p2.longitude);

    return 2 *
        // Use the equatorial radius because we only care about Singapore.
        _equatorialRadius *
        asin(sqrt(_haversin(phi2 - phi1) +
            cos(phi1) * cos(phi2) * _haversin(lambda2 - lambda1)));
  }

  /// The equatorial radius in km.
  ///
  /// See https://en.wikipedia.org/wiki/Earth_radius.
  static const double _equatorialRadius = 6378.137;

  /// Calculates the haversin of a value.
  static double _haversin(double rad) {
    return (1 - cos(rad)) / 2;
  }
}
