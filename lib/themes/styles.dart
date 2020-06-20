import 'package:flutter/material.dart';

/// The style for small-size text.
const TextStyle smallText = TextStyle(fontSize: 12.0);

/// The style for medium-size text.
const TextStyle mediumText = TextStyle(fontSize: 14.0);

/// The style for large-size text.
const TextStyle largeText = TextStyle(
  fontSize: 100.0,
  fontWeight: FontWeight.bold,
);

/// The maximum length of a weather condition in the display.
const int maxConditionLength = 24;

/// The maximum length of a provider name in the display.
const int maxProviderNameLength = 18;

/// The size of small icons.
const double smallIconSize = 10.0;

/// The size of medium icons.
const double mediumIconSize = 48.0;

/// The size of large icons.
const double largeIconSize = 100.0;

/// The color to use to highlight error values.
const Color errorColor = Colors.red;

/// The color to use to highlight out-of-date values.
///
/// Used for main display items outside the details panel.
final Color outOfDateColor = Colors.grey;

/// The style for small-size text with error highlight.
final TextStyle smallTextWithError = smallText.copyWith(color: errorColor);

/// The style for large-size text with error highlight.
final TextStyle largeTextWithError = largeText.copyWith(color: errorColor);

/// The style for large-size text with out-of-date highlight.
final TextStyle largeTextWithOutOfDate =
    largeText.copyWith(color: outOfDateColor);

/// The pattern for displaying [DateTime]s to the user.
const String dateTimePattern = 'd MMM h:mm';

/// The app light theme.
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: Color(0xFFFF5722),
  primaryColorLight: Color(0xFFFFCCBC),
  primaryColorDark: Color(0xFFE64A19),
  accentColor: Color(0xFFFF9800),
);

/// The app dark theme.
final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: Color(0xFFFF5722),
  primaryColorLight: Color(0xFFFFCCBC),
  primaryColorDark: Color(0xFFE64A19),
  accentColor: Color(0xFFFF9800),
);
