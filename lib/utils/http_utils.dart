import 'dart:convert';

import 'package:http/http.dart';

/// Gets JSON data from the internet.
Future<dynamic> httpGetJsonData(String url) async {
  Response response = await get(
    url,
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    try {
      return jsonDecode(response.body);
    } catch (exception) {
      print(exception);
    }
  } else {
    print(response.statusCode);
  }

  return null;
}
