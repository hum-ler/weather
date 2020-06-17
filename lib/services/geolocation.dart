import 'package:geolocator/geolocator.dart';

import '../models/geoposition.dart';

/// The geolocation service.
class Geolocation {
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
