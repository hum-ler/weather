import 'package:flutter_test/flutter_test.dart';

import 'package:weather/models/geoposition.dart';

void main() {
  // From Google Maps, distance from:
  // (i) Rainbow Bridge (Kranji) (1.433188, 103.760812) to:
  // (ii) Statue of Raffles (Boat Quay) (1.287687, 103.850813) is 19.02km.
  // Google Maps probably use a different Earth radius, so we need to give a
  // good tolerance (say, 50m) for the distance.
  const Geoposition bridge = Geoposition(
    latitude: 1.433188,
    longitude: 103.760812,
  );
  const Geoposition statue = Geoposition(
    latitude: 1.287687,
    longitude: 103.850813,
  );

  test('getApproximateDistance()', () {
    expect(
      Geoposition.getApproximateDistance(bridge, bridge),
      moreOrLessEquals(0.0),
    );
    expect(
      Geoposition.getApproximateDistance(statue, statue),
      moreOrLessEquals(0.0),
    );
    expect(
      Geoposition.getApproximateDistance(bridge, statue),
      moreOrLessEquals(19.02, epsilon: 0.05),
    );
    expect(
      Geoposition.getApproximateDistance(statue, bridge),
      moreOrLessEquals(19.02, epsilon: 0.05),
    );
  });

  test('.distanceFrom()', () {
    expect(bridge.distanceFrom(bridge), moreOrLessEquals(0.0));
    expect(statue.distanceFrom(statue), moreOrLessEquals(0.0));
    expect(bridge.distanceFrom(statue), moreOrLessEquals(19.02, epsilon: 0.05));
    expect(statue.distanceFrom(bridge), moreOrLessEquals(19.02, epsilon: 0.05));
  });
}
