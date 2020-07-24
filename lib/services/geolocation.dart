import 'package:geolocator/geolocator.dart';
import 'package:kiwi/kiwi.dart';

import '../models/geoposition.dart';

/// The geolocation service.
class Geolocation {
  /// Gets the user's current location.
  Future<Geoposition> getCurrentLocation({Duration timeout}) async {
    Geolocator geolocator = KiwiContainer().resolve<Geolocator>();
    try {
      Position position = await geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
          .timeout(
            timeout ?? _getCurrentLocationTimeout,
            onTimeout: () => null,
          );

      if (position != null) {
        return Geoposition(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } on Exception {}

    return null;
  }

  /// The timeout period for [getCurrentLocation()].
  ///
  /// As we are using only ACCESS_COARSE_LOCATION, the location information will
  /// come from NETWORK_PROVIDER, which should be really fast.
  static const Duration _getCurrentLocationTimeout = Duration(seconds: 10);
}
