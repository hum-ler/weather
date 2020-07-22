import 'package:flutter_test/flutter_test.dart';

import 'package:weather/utils/string_ext.dart';

void main() {
  const String someValue = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  test('truncate(): invalid maxLength => ArgumentError', () {
    expect(() => someValue.truncate(null), throwsArgumentError);
    expect(() => someValue.truncate(0), throwsArgumentError);
    expect(() => someValue.truncate(-1), throwsArgumentError);
  });

  test('truncate(): null ellipsis equals no ellipsis', () {
    expect(
      someValue.truncate(10),
      equals(someValue.substring(0, 10)),
    );

    expect(
      someValue.truncate(10, ellipsis: null),
      equals(someValue.substring(0, 10)),
    );

    expect(
      someValue.truncate(10, ellipsis: ''),
      equals(someValue.substring(0, 10)),
    );
  });

  test('truncate(): invalid ellipsis => ArgumentError', () {
    expect(() => 'abc'.truncate(2, ellipsis: '...'), throwsArgumentError);
    expect(() => 'abc'.truncate(3, ellipsis: '...'), throwsArgumentError);
    expect(() => 'abc'.truncate(3, ellipsis: '....'), throwsArgumentError);
  });

  test('truncate(): valid input', () {
    const String shortValue = 'abcde';

    expect(someValue.truncate(5), equals('ABCDE'));

    expect(shortValue.truncate(5), equals(shortValue));
    expect(shortValue.truncate(10), equals(shortValue));

    expect(shortValue.truncate(6, ellipsis: '...'), equals('abcde'));
    expect(shortValue.truncate(5, ellipsis: '...'), equals('abcde'));
    expect(shortValue.truncate(4, ellipsis: '.'), equals('abc.'));
    expect(shortValue.truncate(4, ellipsis: '..'), equals('ab..'));
    expect(shortValue.truncate(4, ellipsis: '...'), equals('a...'));
  });

  test('asEnumLabel()', () {
    expect(''.asEnumLabel(), equals(''));
    expect('a'.asEnumLabel(), equals('a'));
    expect('aa'.asEnumLabel(), equals('aa'));
    expect('aa.b'.asEnumLabel(), equals('b'));
    expect('aa.bb'.asEnumLabel(), equals('bb'));
    expect('a.b.c'.asEnumLabel(), equals('b.c'));
  });

  test('capitalize()', () {
    expect(''.capitalize(), equals(''));
    expect('a'.capitalize(), equals('A'));
    expect('A'.capitalize(), equals('A'));
    expect('ab'.capitalize(), equals('Ab'));
    expect('abc'.capitalize(), equals('Abc'));
    expect('.abc'.capitalize(), equals('.abc'));
  });
}
