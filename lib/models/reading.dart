import 'package:flutter/foundation.dart';

import 'geoposition.dart';
import 'provider.dart';

/// A weather reading.
@immutable
class Reading {
  /// The type of this reading.
  final ReadingType type;

  /// The time of creation of this reading, as reported by the provider.
  final DateTime creation;

  /// The numerical value of this reading.
  final num value;

  /// The provider of this reading.
  final Provider provider;

  /// The location of the user that requested this reading.
  final Geoposition userLocation;

  /// The maximum (reasonable) value for this reading type.
  num get upperBound => _upperBound[type];

  /// The minimum (reasonable) value for this reading type.
  num get lowerBound => _lowerBound[type];

  /// Indicates whether the value is within reasonable boundaries.
  bool get isInBounds => lowerBound <= value && upperBound >= value;

  /// The validity period for this reading type.
  Duration get validityPeriod => _validityPeriod[type];

  /// The expiry time of this reading.
  final DateTime expiry;

  /// Indicates whether this reading is already expired.
  bool get isExpired => DateTime.now().isAfter(expiry);

  /// The distance of the user from the provider.
  final double distance;

  /// Indicates whether [distance] is within reasonable range.
  bool get isNearby => distance <= provider.effectiveRange;

  /// Indicates whether this reading is healthy overall.
  bool get isValid => isInBounds && !isExpired && isNearby;

  Reading({
    @required this.type,
    @required this.creation,
    @required this.value,
    @required this.provider,
    @required this.userLocation,
  })  : assert(type != null),
        assert(creation != null),
        assert(value != null),
        assert(provider != null),
        assert(userLocation != null),
        expiry = creation.add(_validityPeriod[type]),
        distance = userLocation.distanceFrom(provider.location);

  /// The validaty period for each [ReadingType].
  static const Map<ReadingType, Duration> _validityPeriod = {
    ReadingType.temperature: const Duration(minutes: 1),
    ReadingType.rainfall: const Duration(minutes: 5),
    ReadingType.humidity: const Duration(minutes: 1),
    ReadingType.windSpeed: const Duration(minutes: 1),
    ReadingType.windDirection: const Duration(minutes: 1),
    ReadingType.pm2_5: const Duration(hours: 1),
  };

  /// The minimum (reasonable) value for each [ReadingType].
  static const Map<ReadingType, num> _lowerBound = {
    ReadingType.temperature: 20.0,
    ReadingType.rainfall: 0.0,
    ReadingType.humidity: 0.0,
    ReadingType.windSpeed: 0.0,
    ReadingType.windDirection: 0,
    ReadingType.pm2_5: 0,
  };

  /// The maximum (reasonable) value for each [ReadingType].
  static const Map<ReadingType, num> _upperBound = {
    ReadingType.temperature: 40.0,
    ReadingType.rainfall: 100.0,
    ReadingType.humidity: 100.0,
    ReadingType.windSpeed: 100.0,
    ReadingType.windDirection: 360,
    ReadingType.pm2_5: 300,
  };
}

/// The types of reading.
enum ReadingType {
  temperature,
  rainfall,
  humidity,
  windSpeed,
  windDirection,
  pm2_5,
}
