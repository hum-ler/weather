import 'package:flutter/material.dart';

import 'routes/home.dart';
import 'themes/themes.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: Themes.light,
    darkTheme: Themes.dark,
  ));
}
