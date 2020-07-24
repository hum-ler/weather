import 'package:flutter_test/flutter_test.dart';

import 'package:weather/models/reading.dart';
import 'package:weather/models/geoposition.dart';
import 'package:weather/models/provider.dart';

void main() {
  test('.isExpired: current .creation', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: 0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.creation, isNotNull);
    expect(reading.expiry, isNotNull);
    expect(reading.validityPeriod, isNotNull);
    expect(
      reading.expiry,
      equals(reading.creation.add(reading.validityPeriod)),
    );
    expect(reading.isExpired, isFalse);
  });

  test('.isExpired: .creation from way past', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: 0,
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.creation, isNotNull);
    expect(reading.expiry, isNotNull);
    expect(reading.validityPeriod, isNotNull);
    expect(
      reading.expiry,
      equals(reading.creation.add(reading.validityPeriod)),
    );
    expect(reading.isExpired, isTrue);
  });

  test('.isExpired: .creation is way in the future', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: 0,
      creation: DateTime(3000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.creation, isNotNull);
    expect(reading.expiry, isNotNull);
    expect(reading.validityPeriod, isNotNull);
    expect(
      reading.expiry,
      equals(reading.creation.add(reading.validityPeriod)),
    );
    expect(reading.isExpired, isFalse);
  });

  test('.isNearBy: .userLocation is near by', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: 0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isNearby, isTrue);
  });

  test('.isNearBy: .userLocation is far, far away', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: 0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(reading.isNearby, isFalse);
  });

  test('.isInBounds: .value is too low', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: -200.0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isInBounds, isFalse);
  });

  test('.isInBounds: .value is too high', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: 200.0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isInBounds, isFalse);
  });

  test('.isInBounds: typical .value', () {
    final Reading reading = Reading(
      type: ReadingType.temperature,
      value: 25.0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isInBounds, isTrue);
  });

  test('.isValid: equals .isInBounds and .isNearBy and not .isExpired', () {
    Reading reading = Reading(
      type: ReadingType.temperature,
      value: 25.0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isInBounds, isTrue);
    expect(reading.isNearby, isTrue);
    expect(reading.isExpired, isFalse);
    expect(reading.isValid, isTrue);

    reading = Reading(
      type: ReadingType.temperature,
      value: -200.0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isInBounds, isFalse);
    expect(reading.isNearby, isTrue);
    expect(reading.isExpired, isFalse);
    expect(reading.isValid, isFalse);

    reading = Reading(
      type: ReadingType.temperature,
      value: 25.0,
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isInBounds, isTrue);
    expect(reading.isNearby, isTrue);
    expect(reading.isExpired, isTrue);
    expect(reading.isValid, isFalse);

    reading = Reading(
      type: ReadingType.temperature,
      value: 25.0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(reading.isInBounds, isTrue);
    expect(reading.isNearby, isFalse);
    expect(reading.isExpired, isFalse);
    expect(reading.isValid, isFalse);

    reading = Reading(
      type: ReadingType.temperature,
      value: -200.0,
      creation: DateTime.now(),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(reading.isInBounds, isFalse);
    expect(reading.isNearby, isFalse);
    expect(reading.isExpired, isFalse);
    expect(reading.isValid, isFalse);

    reading = Reading(
      type: ReadingType.temperature,
      value: -200.0,
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Providers.central.location,
    );
    expect(reading.isInBounds, isFalse);
    expect(reading.isNearby, isTrue);
    expect(reading.isExpired, isTrue);
    expect(reading.isValid, isFalse);

    reading = Reading(
      type: ReadingType.temperature,
      value: 25.0,
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(reading.isInBounds, isTrue);
    expect(reading.isNearby, isFalse);
    expect(reading.isExpired, isTrue);
    expect(reading.isValid, isFalse);

    reading = Reading(
      type: ReadingType.temperature,
      value: -200.0,
      creation: DateTime(1000),
      provider: Providers.central,
      userLocation: Geoposition(
        latitude: 1.0,
        longitude: 2.0,
      ),
    );
    expect(reading.isInBounds, isFalse);
    expect(reading.isNearby, isFalse);
    expect(reading.isExpired, isTrue);
    expect(reading.isValid, isFalse);
  });
}
