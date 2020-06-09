import 'package:flutter/material.dart';

import 'package:weather/pages/home.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
  ));
}
