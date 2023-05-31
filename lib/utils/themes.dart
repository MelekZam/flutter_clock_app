import 'package:flutter/material.dart';

class Themes {
  static ThemeData dark = ThemeData(
    fontFamily: 'RobotoMono',
    primarySwatch: Colors.indigo,
    brightness: Brightness.dark,
  );

  static ThemeData light = ThemeData(
    fontFamily: 'RobotoMono',
    primarySwatch: Colors.indigo,
    brightness: Brightness.light,
  );

  static ThemeData currentTheme(String mode) {
    if (mode == 'dark') {
      return dark;
    }
    return light;
  }
}
