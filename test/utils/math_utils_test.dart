import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:weather/utils/math_utils.dart';

void main() {
  test('degreesToRadians()', () {
    expect(degreesToRadians(0), moreOrLessEquals(0));
    expect(degreesToRadians(90), moreOrLessEquals(pi / 2));
    expect(degreesToRadians(180), moreOrLessEquals(pi));
    expect(degreesToRadians(270), moreOrLessEquals(3 * pi / 2));
    expect(degreesToRadians(360), moreOrLessEquals(2 * pi));
    expect(degreesToRadians(-90), moreOrLessEquals(-pi / 2));
    expect(degreesToRadians(-180), moreOrLessEquals(-pi));
    expect(degreesToRadians(-270), moreOrLessEquals(-3 * pi / 2));
    expect(degreesToRadians(-360), moreOrLessEquals(-2 * pi));
  });
}
