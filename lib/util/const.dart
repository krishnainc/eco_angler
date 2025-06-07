import 'package:flutter/material.dart';
class Constants{

  static String appName = "EcoAngler";

  //Colors for theme
//  Color(0xfffcfcff);
  static Color lightPrimary = Color(0xfffcfcff);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Colors.red;
  static Color? darkAccent = Colors.red[400];
  static Color lightBG = Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color? ratingBG = Colors.yellow[600];

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    hintColor: lightAccent,
    cardColor: lightAccent,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: darkBG),
      titleTextStyle: TextStyle(
        color: darkBG,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),
  );


  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    hintColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cardColor: darkAccent,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: lightBG),
      titleTextStyle: TextStyle(
        color: lightBG,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),
    colorScheme: ColorScheme.dark(
      background: darkBG,
      primary: darkPrimary,
      secondary: darkAccent ?? Colors.blueAccent,
    ),
  );



}