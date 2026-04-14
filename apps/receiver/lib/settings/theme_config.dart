import 'package:flutter/material.dart';

ThemeData createThemeData(BuildContext context) {
  double textHeight = 1.3;
  Color textColor = Colors.white;
  return ThemeData(
    splashFactory: NoSplash.splashFactory,
    primarySwatch: Colors.blue,
    // Set App background color
    scaffoldBackgroundColor: Colors.black,
    // Set Text default body color
    textTheme: Theme.of(context)
        .textTheme
        .copyWith(
          displayLarge: TextStyle(
            height: textHeight,
          ),
          displayMedium: TextStyle(
            height: textHeight,
          ),
          displaySmall: TextStyle(
            height: textHeight,
          ),
          headlineLarge: TextStyle(
            height: textHeight,
          ),
          headlineMedium: TextStyle(
            height: textHeight,
          ),
          headlineSmall: TextStyle(
            height: textHeight,
          ),
          titleLarge: TextStyle(
            height: textHeight,
          ),
          titleMedium: TextStyle(
            height: textHeight,
          ),
          titleSmall: TextStyle(
            height: textHeight,
          ),
          bodyLarge: TextStyle(
            height: textHeight,
          ),
          bodyMedium: TextStyle(
            height: textHeight,
          ),
          bodySmall: TextStyle(
            height: textHeight,
          ),
          labelLarge: TextStyle(
            height: textHeight,
          ),
          labelMedium: TextStyle(
            height: textHeight,
          ),
          labelSmall: TextStyle(
            height: textHeight,
          ),
        )
        .apply(
          fontFamily: 'Inter',
          bodyColor: textColor,
          displayColor: textColor,
        ),
    // Set ElevatedButton default foreground color
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(foregroundColor: textColor),
    ),
    // Set TextButton default foreground color
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: textColor),
    ),
    // Set IconButton default foreground color
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: textColor),
    ),
    // Set Icon default color
    iconTheme: IconThemeData(
      color: textColor,
    ),
    listTileTheme: ListTileThemeData(
      textColor: textColor,
      iconColor: textColor,
    ),
  );
}
