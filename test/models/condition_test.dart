import 'package:flutter_test/flutter_test.dart';

import 'package:weather/models/condition.dart';
import 'package:weather/models/geoposition.dart';
import 'package:weather/models/provider.dart';

void main() {
  test('.isExpired: current .creation', () {
    final Condition condition = Condition(
      condition: '',
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(condition.creation, isNotNull);
    expect(condition.expiry, isNotNull);
    expect(condition.validityPeriod, isNotNull);
    expect(
      condition.expiry,
      equals(condition.creation.add(condition.validityPeriod)),
    );
    expect(condition.isExpired, isFalse);
  });

  test('.isExpired: .creation from way past', () {
    final Condition condition = Condition(
      condition: '',
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(condition.creation, isNotNull);
    expect(condition.expiry, isNotNull);
    expect(condition.validityPeriod, isNotNull);
    expect(
      condition.expiry,
      equals(condition.creation.add(condition.validityPeriod)),
    );
    expect(condition.isExpired, isTrue);
  });

  test('.isExpired: .creation is way in the future', () {
    final Condition condition = Condition(
      condition: '',
      creation: DateTime(3000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(condition.creation, isNotNull);
    expect(condition.expiry, isNotNull);
    expect(condition.validityPeriod, isNotNull);
    expect(
      condition.expiry,
      equals(condition.creation.add(condition.validityPeriod)),
    );
    expect(condition.isExpired, isFalse);
  });

  test('.isNearBy: .userLocation is near by', () {
    final Condition condition = Condition(
      condition: '',
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(condition.isNearby, isTrue);
  });

  test('.isNearBy: .userLocation is far, far away', () {
    final Condition condition = Condition(
      condition: '',
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(condition.isNearby, isFalse);
  });

  test('.isValid: equals .isNearBy and not .isExpired', () {
    Condition condition = Condition(
      condition: '',
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(condition.isNearby, isTrue);
    expect(condition.isExpired, isFalse);
    expect(condition.isValid, isTrue);

    condition = Condition(
      condition: '',
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(condition.isNearby, isTrue);
    expect(condition.isExpired, isTrue);
    expect(condition.isValid, isFalse);

    condition = Condition(
      condition: '',
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(condition.isNearby, isFalse);
    expect(condition.isExpired, isFalse);
    expect(condition.isValid, isFalse);

    condition = Condition(
      condition: '',
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(condition.isNearby, isFalse);
    expect(condition.isExpired, isTrue);
    expect(condition.isValid, isFalse);
  });
}
