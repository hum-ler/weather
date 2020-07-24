import 'dart:convert';

import 'package:http/http.dart';

/// Gets JSON data from the internet.
///
/// Caller must handle the closing of [client].
Future<dynamic> httpGetJsonData(
  String url,
  Client client, {
  Duration timeout,
}) async {
  if (url == null || client == null) return null;

  try {
    Response response = await client.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(
      timeout ?? _httpGetJsonDataTimeout,
      onTimeout: () => null,
    );

    if (response?.statusCode == 200) return jsonDecode(response.body);
  } on Exception {}

  return null;
}

/// The timeout period for [httpGetJsonData()].
const Duration _httpGetJsonDataTimeout = Duration(seconds: 10);
