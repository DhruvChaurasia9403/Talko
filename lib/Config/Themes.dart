// File: Config/Themes.dart
import 'package:chatting/Config/colors.dart';
import 'package:flutter/material.dart';

var lightTheme = ThemeData();

var darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: dBackgroundColor,

    appBarTheme: const AppBarTheme(
      backgroundColor: dBackgroundColor, // Transparent/Black appbars look more modern
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: dOnBackgroundColor),
    ),

    inputDecorationTheme: InputDecorationTheme(
        fillColor: dContainerColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(25), // Pill-shaped inputs are modern
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: dPrimaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(25),
        )
    ),

    colorScheme: const ColorScheme.dark(
      primary: dPrimaryColor,
      onPrimary: dBackgroundColor, // Dark text on gold buttons
      secondary: dSecondaryColor,
      surface: dBackgroundColor,
      onSurface: dOnBackgroundColor,
      primaryContainer: dContainerColor,
      onPrimaryContainer: dOnContainerColor,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, color: dPrimaryColor, fontFamily: "Poppins", fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(fontSize: 28, color: dOnBackgroundColor, fontFamily: "Poppins", fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontSize: 20, color: dOnBackgroundColor, fontFamily: "Poppins", fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, color: dOnBackgroundColor, fontFamily: "Poppins", fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14, color: dOnBackgroundColor, fontFamily: "Poppins", fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, color: dOnContainerColor, fontFamily: "Poppins", fontWeight: FontWeight.w400),
      labelSmall: TextStyle(fontSize: 11, color: dOnContainerColor, fontFamily: "Poppins", fontWeight: FontWeight.w300),
    )
);