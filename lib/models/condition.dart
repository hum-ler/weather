import 'package:flutter/material.dart';

import 'package:weather_icons/weather_icons.dart';

import 'geoposition.dart';
import 'provider.dart';

/// A weather condition.
@immutable
class Condition {
  /// The time of creation of this condition, as reported by the provider.
  final DateTime creation;

  /// The literal weather condition.
  final String condition;

  /// The provider of this condition.
  final Provider provider;

  /// The location of the user that requested this condition.
  final Geoposition userLocation;

  /// The validity period of this condition.
  Duration get validityPeriod => _validityPeriod;

  /// The expiry time of this condition.
  final DateTime expiry;

  /// Indicates whether this condition is already expired.
  bool get isExpired => DateTime.now().isAfter(expiry);

  /// The distance of the user from the provider.
  final double distance;

  /// The unit for [distance].
  String get distanceUnit => 'km';

  /// Indicates whether [distance] is within reasonable range.
  bool get isNearby => distance <= provider.effectiveRange;

  /// Indicates whether this condition is healthy overall.
  bool get isValid => !isExpired && isNearby;

  /// The icon that represents this condition.
  ///
  /// Provided by WeatherIcons. Use [BoxedIcon()] to ensure correct display.
  IconData get icon => _icons[condition] ?? WeatherIcons.na;

  Condition({
    @required this.creation,
    @required this.condition,
    @required this.provider,
    @required this.userLocation,
  })  : assert(creation != null),
        assert(condition != null),
        assert(provider != null),
        assert(userLocation != null),
        expiry = creation.add(_validityPeriod),
        distance = userLocation.distanceFrom(provider.location);

  /// The validity period for a condition.
  static const Duration _validityPeriod = Duration(hours: 2);

  /// The icons that represents each [condition].
  static const Map<String, IconData> _icons = {
    'Cloudy': WeatherIcons.cloudy,
    'Fair (Day)': WeatherIcons.day_sunny,
    'Fair (Night)': WeatherIcons.night_clear,
    'Hazy': WeatherIcons.dust,
    'Hazy (Day)': WeatherIcons.day_haze,
    'Hazy (Night)': WeatherIcons.dust,
    'Heavy Thundery Showers': WeatherIcons.storm_showers,
    'Heavy Thundery Showers with Gusty Winds': WeatherIcons.storm_showers,
    'Light Rain': WeatherIcons.rain,
    'Light Showers': WeatherIcons.showers,
    'Moderate Rain': WeatherIcons.rain,
    'Overcast': WeatherIcons.cloudy,
    'Partly Cloudy': WeatherIcons.cloud,
    'Partly Cloudy (Day)': WeatherIcons.day_sunny_overcast,
    'Partly Cloudy (Night)': WeatherIcons.night_alt_partly_cloudy,
    'Rain': WeatherIcons.rain,
    'Rain (Day)': WeatherIcons.day_rain,
    'Rain (Night)': WeatherIcons.night_alt_rain,
    'Showers': WeatherIcons.showers,
    'Showers (Day)': WeatherIcons.day_showers,
    'Showers (Night)': WeatherIcons.night_alt_showers,
    'Thundery Showers': WeatherIcons.storm_showers,
    'Thundery Showers (Day)': WeatherIcons.day_storm_showers,
    'Thundery Showers (Night)': WeatherIcons.night_alt_storm_showers,
    'Windy': WeatherIcons.strong_wind,
  };
}
