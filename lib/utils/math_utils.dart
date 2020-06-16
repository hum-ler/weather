import 'dart:math';

import 'constants.dart' as constants;

/// Converts from degrees to radians.
double degreesToRadians(double deg) => deg * pi / 180;

/// Converts from knots to meters per second.
double knotsToMetersPerSecond(num knots) {
  return knots * constants.knotToMetersPerSecond;
}
