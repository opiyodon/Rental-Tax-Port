import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    buttonColor: Colors.blue,
    textTheme: ButtonTextTheme.primary,
  ),
);