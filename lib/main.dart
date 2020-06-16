import 'package:flutter/material.dart';

import 'pages/home.dart';
import 'utils/config.dart' as config;

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: config.lightTheme,
    darkTheme: config.darkTheme,
  ));
}
