import 'package:flutter_test/flutter_test.dart';

import 'package:weather/utils/date_time_ext.dart';

void main() {
  const String someValue = '2006-06-06T06:06:06';
  const String someFormat = 'yyyy-MM-ddTHH:mm:ss';

  test('format(): valid pattern', () {
    expect(DateTime.parse(someValue).format(someFormat), equals(someValue));
  });

  test('format(): null pattern equals some system default', () {
    expect(
        DateTime.parse(someValue).format(null),
        allOf([
          isNotNull,
          isNotEmpty,
        ]));
  });
}
