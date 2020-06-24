import 'package:flutter/material.dart';

/// The style that applies to text and icon in this app.
@immutable
class Style {
  // Cache the 2 styles.
  static final Style _light = Style._style(Brightness.light);
  static final Style _dark = Style._style(Brightness.dark);

  Style._style(this._brightness);

  factory Style(Brightness brightness) {
    if (brightness == Brightness.light) return _light;

    return _dark;
  }

  /// The brightness of the theme.
  final Brightness _brightness;

  /// The style for small-size text.
  final TextStyle smallText = TextStyle(fontSize: 12.0);

  /// The style for medium-size text.
  final TextStyle mediumText = TextStyle(fontSize: 14.0);

  /// The style for large-size text.
  final TextStyle largeText = TextStyle(
    fontSize: 100.0,
    fontWeight: FontWeight.bold,
  );

  /// The maximum length of a weather condition in the display.
  final int maxConditionLength = 24;

  /// The maximum length of a provider name in the display.
  final int maxProviderNameLength = 18;

  /// The size of small icons.
  final double smallIconSize = 10.0;

  /// The size of medium icons.
  final double mediumIconSize = 48.0;

  /// The size of large icons.
  final double largeIconSize = 100.0;

  /// The pattern for displaying [DateTime]s to the user.
  final String dateTimePattern = 'd MMM h:mm';

  /// The color to use to highlight values with error.
  Color get _smallErrorColor {
    return _brightness == Brightness.light ? Colors.red : Colors.amber;
  }

  /// The color to use to highlight values with error.
  final Color _largeErrorColor = Colors.grey;

  /// The style for small-size text with error highlight.
  TextStyle get smallTextWithError {
    return smallText.copyWith(color: _smallErrorColor);
  }

  /// The color for small-size icons with error highlight.
  Color get smallIconWithError => _smallErrorColor;

  /// The style for medium-size text with error highlight.
  TextStyle get mediumTextWithError {
    return mediumText.copyWith(color: _largeErrorColor);
  }

  /// The color for medium-size icons with error highlight.
  Color get mediumIconWithError => _largeErrorColor;

  /// The style for large-size text with error highlight.
  TextStyle get largeTextWithError {
    return largeText.copyWith(color: _largeErrorColor);
  }

  /// The color for large-size icon with error highlight.
  Color get largeIconWithError => _largeErrorColor;
}
