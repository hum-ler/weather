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
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
          .timeout(
            _getCurrentLocationTimeout,
            onTimeout: () => null,
          );

      if (position != null) {
        return Geoposition(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (exception) {
      print(exception);
    }

    return null;
  }

  /// The timeout period for [getCurrentLocation()].
  ///
  /// As we are using only ACCESS_COARSE_LOCATION, the locaton information will
  /// come from NETWORK_PROVIDER, which should be really fast.
  static const Duration _getCurrentLocationTimeout = Duration(seconds: 10);
}
