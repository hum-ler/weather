import 'dart:math';

import 'package:geolocator/geolocator.dart';

import 'package:weather/models/geoposition.dart';
import 'package:weather/utils/constants.dart' as constants;
import 'package:weather/utils/utils.dart';

/// The geolocation service.
class Geolocation {
  Future<Geoposition> getCurrentLocation() async {
    Position position = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    if (position != null) {
      return Geoposition(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    return null;
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
        constants.meanEarthRadius *
        asin(sqrt(_haversin(phi2 - phi1) +
            cos(phi1) * cos(phi2) * _haversin(lambda2 - lambda1)));
  }

  static double _haversin(double rad) {
    return (1 - cos(rad)) / 2;
  }
}
