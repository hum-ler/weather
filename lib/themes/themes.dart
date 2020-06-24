import 'package:flutter/material.dart';

class Themes {
  static final ThemeData dark = ThemeData.dark().copyWith(
    primaryColor: Color(0xFFFF5722),
    primaryColorLight: Color(0xFFFFCCBC),
    primaryColorDark: Color(0xFFE64A19),
    accentColor: Color(0xFFFF9800),
    snackBarTheme: ThemeData.dark()
        .snackBarTheme
        .copyWith(actionTextColor: Color(0xFFFF5722)),
  );

  static final ThemeData light = ThemeData.light().copyWith(
    primaryColor: Color(0xFFFF5722),
    primaryColorLight: Color(0xFFFFCCBC),
    primaryColorDark: Color(0xFFE64A19),
    accentColor: Color(0xFFFF9800),
    snackBarTheme: ThemeData.light()
        .snackBarTheme
        .copyWith(actionTextColor: Color(0xFFFF9800)),
  );
}
