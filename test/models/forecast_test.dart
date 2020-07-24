import 'package:flutter_test/flutter_test.dart';

import 'package:weather/models/forecast.dart';
import 'package:weather/models/provider.dart';

void main() {
  test('.isExpired: current .creation', () {
    final Forecast forecast = Forecast(
      type: ForecastType.immediate,
      condition: '',
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(forecast.creation, isNotNull);
    expect(forecast.expiry, isNotNull);
    expect(forecast.validityPeriod, isNotNull);
    expect(
      forecast.expiry,
      equals(forecast.creation.add(forecast.validityPeriod)),
    );
    expect(forecast.isExpired, isFalse);
  });

  test('.isExpired: .creation from way past', () {
    final Forecast forecast = Forecast(
      type: ForecastType.immediate,
      condition: '',
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(forecast.creation, isNotNull);
    expect(forecast.expiry, isNotNull);
    expect(forecast.validityPeriod, isNotNull);
    expect(
      forecast.expiry,
      equals(forecast.creation.add(forecast.validityPeriod)),
    );
    expect(forecast.isExpired, isTrue);
  });

  test('.isExpired: .creation is way in the future', () {
    final Forecast forecast = Forecast(
      type: ForecastType.immediate,
      condition: '',
      creation: DateTime(3000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(forecast.creation, isNotNull);
    expect(forecast.expiry, isNotNull);
    expect(forecast.validityPeriod, isNotNull);
    expect(
      forecast.expiry,
      equals(forecast.creation.add(forecast.validityPeriod)),
    );
    expect(forecast.isExpired, isFalse);
  });
}
