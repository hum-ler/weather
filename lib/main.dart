import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';
import 'routes/home.dart';
import 'themes/themes.dart';

void main() {
  runApp(MaterialApp(
    localizationsDelegates: [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Home(),
    theme: Themes.light,
    darkTheme: Themes.dark,
  ));
}
