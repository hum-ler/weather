import 'package:geolocator/geolocator.dart';

import '../models/geoposition.dart';

/// The geolocation service.
class Geolocation {
  // Use a singleton for this service.
  static final Geolocation _singleton = Geolocation._geolocation();

  Geolocation._geolocation();

  factory Geolocation() => _singleton;

  /// Gets the user's current location.
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
}
