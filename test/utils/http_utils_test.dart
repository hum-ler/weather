import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

import 'package:weather/utils/http_utils.dart';

class MockClient extends Mock implements Client {}

void main() {
  const String someUrl = 'https://some.url';
  const String someHtml = '<!DOCTYPE html><html />';
  const String someJson = '{"key": "value"}';

  test('httpGetJsonData(): null client => null', () {
    expect(httpGetJsonData(someUrl, null), completion(isNull));
  });

  test('httpGetJsonData(): null url => null', () {
    final MockClient client = MockClient();
    when(client.get(null, headers: anyNamed('headers')))
        .thenThrow(Exception(''));

    expect(httpGetJsonData(null, client), completion(isNull));
  });

  test('httpGetJsonData(): no such host => null', () async {
    final MockClient client = MockClient();
    when(client.get(someUrl, headers: anyNamed('headers')))
        .thenThrow(SocketException(''));

    expect(httpGetJsonData(someUrl, client), completion(isNull));
  });

  test('httpGetJsonData(): 404 => null', () {
    final MockClient client = MockClient();
    when(client.get(someUrl, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('', HttpStatus.notFound));

    expect(httpGetJsonData(someUrl, client), completion(isNull));
  });

  test('httpGetJsonData(): non-JSON result => null', () {
    final MockClient client = MockClient();
    when(client.get(someUrl, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response(someHtml, HttpStatus.ok));

    expect(httpGetJsonData(someUrl, client), completion(isNull));
  });

  test('httpGetJsonData(): JSON result', () async {
    final MockClient client = MockClient();
    when(client.get(someUrl, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response(someJson, HttpStatus.ok));

    expect(
        httpGetJsonData(someUrl, client),
        completion(allOf([
          isNotNull,
          isNotEmpty,
        ])));
  });
}
