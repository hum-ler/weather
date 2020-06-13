import 'package:flutter/material.dart';

import 'package:weather/pages/home.dart';
import 'package:weather/utils/constants.dart' as constants;

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: constants.lightTheme,
    darkTheme: constants.darkTheme,
  ));
}
