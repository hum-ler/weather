import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kiwi/kiwi.dart';
import 'package:mockito/mockito.dart';

import 'package:weather/models/geoposition.dart';
import 'package:weather/services/geolocation.dart';

class MockGeolocator extends Mock implements Geolocator {}

void main() {
  test('.getCurrentLocation(): null result => null', () {
    final Geolocator geolocator = MockGeolocator();
    when(geolocator.getCurrentPosition(
            desiredAccuracy: anyNamed('desiredAccuracy')))
        .thenAnswer((_) async => null);
    KiwiContainer()
      ..clear()
      ..registerInstance<Geolocator>(geolocator);

    final Geolocation geolocation = Geolocation();
    expect(geolocation.getCurrentLocation(), completion(isNull));
  });

  test('.getCurrentLocation(): PlatformException => null', () {
    final Geolocator geolocator = MockGeolocator();
    when(geolocator.getCurrentPosition(
            desiredAccuracy: anyNamed('desiredAccuracy')))
        .thenThrow(PlatformException(code: ''));
    KiwiContainer()
      ..clear()
      ..registerInstance<Geolocator>(geolocator);

    final Geolocation geolocation = Geolocation();
    expect(geolocation.getCurrentLocation(), completion(isNull));
  });

  test('.getCurrentLocation(): timeout => null', () {
    final Geolocator geolocator = MockGeolocator();
    when(geolocator.getCurrentPosition(
            desiredAccuracy: anyNamed('desiredAccuracy')))
        .thenAnswer((_) => Future<Position>.delayed(
              const Duration(seconds: 20),
              () => Position(),
            ));
    KiwiContainer()
      ..clear()
      ..registerInstance<Geolocator>(geolocator);

    final Geolocation geolocation = Geolocation();
    expect(
        geolocation.getCurrentLocation(
          timeout: const Duration(milliseconds: 250),
        ),
        completion(isNull));
  });

  test('.getCurrentLocation()', () async {
    final Geolocator geolocator = MockGeolocator();
    when(geolocator.getCurrentPosition(
            desiredAccuracy: anyNamed('desiredAccuracy')))
        .thenAnswer((_) async => Position(latitude: 1.0, longitude: 2.0));
    KiwiContainer()
      ..clear()
      ..registerInstance<Geolocator>(geolocator);

    final Geolocation geolocation = Geolocation();
    final Geoposition geoposition = await geolocation.getCurrentLocation();
    expect(geoposition, isNotNull);
    expect(geoposition.latitude, moreOrLessEquals(1.0));
    expect(geoposition.longitude, moreOrLessEquals(2.0));
  });
}
