import 'package:flutter/material.dart';

import 'routes/home.dart';
import 'themes/styles.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: lightTheme,
    darkTheme: darkTheme,
  ));
}
