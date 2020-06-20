import 'dart:convert';

import 'package:http/http.dart';

/// Gets JSON data from the internet.
Future<dynamic> httpGetJsonData(String url) async {
  try {
    Response response = await get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response != null) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
      }
    }
  } catch (exception) {
    print(exception);
  }

  return null;
}
