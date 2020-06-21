import 'package:flutter/foundation.dart';

import 'condition.dart';
import 'geoposition.dart';
import 'provider.dart';

/// A predicted weather condition.
class Forecast extends Condition {
  /// The type of this forecast.
  final ForecastType type;

  /// The validity period of this condition.
  @override
  Duration get validityPeriod => _validityPeriod[type];

  /// The expiry time of this condition.
  @override
  final DateTime expiry;

  Forecast({
    @required this.type,
    @required DateTime creation,
    @required String condition,
    @required Provider provider,
    @required Geoposition userLocation,
  })  : assert(type != null),
        expiry = creation.add(_validityPeriod[type]),
        super(
          creation: creation,
          condition: condition,
          provider: provider,
          userLocation: userLocation,
        );

  /// The validity periods for each [ForecastType].
  static const Map<ForecastType, Duration> _validityPeriod = {
    ForecastType.immediate: const Duration(hours: 2),
    ForecastType.predawn: const Duration(hours: 2),
    ForecastType.morning: const Duration(hours: 2),
    ForecastType.afternoon: const Duration(hours: 2),
    ForecastType.night: const Duration(hours: 2),
  };
}

/// The types of forecast.
enum ForecastType {
  // 2-hour forecast.
  immediate,

  // 24-hour forecast.
  predawn, // 12am to 6am.
  morning, // 6am to 12pm.
  afternoon, // 12pm to 6pm.
  night, // 6pm to 6am, or 6pm to 12am if predawn is present.
}
