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

  /// The unit of this reading.
  String get unit => _units[type];

  /// The provider of this reading.
  final Provider provider;

  /// The location of the user that requested this reading.
  final Geoposition userLocation;

  /// The maximum (reasonable) value for this reading type.
  num get upperBound => _upperBounds[type];

  /// The minimum (reasonable) value for this reading type.
  num get lowerBound => _lowerBounds[type];

  /// Indicates whether the value is within reasonable boundaries.
  bool get isInBounds => lowerBound <= value && upperBound >= value;

  /// The validity period for this reading type.
  Duration get validityPeriod => _validityPeriods[type];

  /// The expiry time of this reading.
  final DateTime expiry;

  /// Indicates whether this reading is already expired.
  bool get isExpired => DateTime.now().isAfter(expiry);

  /// The distance of the user from the provider.
  final double distance;

  /// The unit for [distance].
  String get distanceUnit => 'km';

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
        expiry = creation.add(_validityPeriods[type]),
        distance = userLocation.distanceFrom(provider.location);

  /// The validaty periods for each [ReadingType].
  static const Map<ReadingType, Duration> _validityPeriods = {
    ReadingType.temperature: const Duration(minutes: 10),
    ReadingType.rainfall: const Duration(minutes: 20),
    ReadingType.humidity: const Duration(minutes: 10),
    ReadingType.windSpeed: const Duration(minutes: 10),
    ReadingType.windDirection: const Duration(minutes: 10),
    ReadingType.pm2_5: const Duration(hours: 2),
  };

  /// The minimum (reasonable) values for each [ReadingType].
  static const Map<ReadingType, num> _lowerBounds = {
    ReadingType.temperature: 19.0,
    ReadingType.rainfall: 0.0,
    ReadingType.humidity: 30.0,
    ReadingType.windSpeed: 0.0,
    ReadingType.windDirection: 0,
    ReadingType.pm2_5: 0,
  };

  /// The maximum (reasonable) values for each [ReadingType].
  static const Map<ReadingType, num> _upperBounds = {
    ReadingType.temperature: 37.0,
    ReadingType.rainfall: 96.0,
    ReadingType.humidity: 100.0,
    ReadingType.windSpeed: 25.2,
    ReadingType.windDirection: 360,
    ReadingType.pm2_5: 471,
  };

  /// The units for each [ReadingType].
  static const Map<ReadingType, String> _units = {
    ReadingType.temperature: '°C',
    ReadingType.rainfall: 'mm',
    ReadingType.humidity: '%',
    ReadingType.windSpeed: 'm/s',
    ReadingType.windDirection: '°',
    ReadingType.pm2_5: 'µg/m³',
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
