import 'dart:math';

/// Converts from degrees to radians.
double degreesToRadians(double deg) => deg * pi / 180;

/// Converts from knots to meters per second.
double knotsToMetersPerSecond(num knots) {
  return knots * _knotToMetersPerSecond;
}

/// The conversion factor from knot to m/s.
///
/// See https://en.wikipedia.org/wiki/Knot_(unit).
const double _knotToMetersPerSecond = 0.514444;
