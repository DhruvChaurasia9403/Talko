import 'package:chatting/Config/colors.dart';
import 'package:flutter/material.dart';

// --- LIGHT THEME (Alabaster & Sage) ---
var lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  scaffoldBackgroundColor: lBackgroundColor,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: lTextColor),
  ),

  colorScheme: const ColorScheme.light(
    primary: lPrimaryColor,
    onPrimary: Colors.white,
    secondary: lOrbColor1,
    surface: lBackgroundColor,
    onSurface: lTextColor,
    primaryContainer: lSurfaceColor,
    onPrimaryContainer: lSubTextColor,
  ),

  textTheme: _buildTextTheme(lPrimaryColor, lTextColor, lSubTextColor),
);

// --- DARK THEME (Obsidian & Ember) ---
var darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: dBackgroundColor,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: dTextColor),
  ),

  colorScheme: const ColorScheme.dark(
    primary: dPrimaryColor, // The Amber Accent
    onPrimary: Colors.black,
    secondary: dOrbColor2,
    surface: dBackgroundColor,
    onSurface: dTextColor,
    primaryContainer: dSurfaceColor,
    onPrimaryContainer: dSubTextColor,
  ),

  textTheme: _buildTextTheme(dPrimaryColor, dTextColor, dSubTextColor),
);

// --- UNIVERSAL TYPOGRAPHY ---
TextTheme _buildTextTheme(Color primary, Color onBackground, Color onContainer) {
  return TextTheme(
    displayLarge: TextStyle(fontSize: 40, color: primary, fontFamily: "Poppins", fontWeight: FontWeight.w900),
    displaySmall: TextStyle(fontSize: 32, color: primary, fontFamily: "Poppins", fontWeight: FontWeight.w800),
    headlineMedium: TextStyle(fontSize: 28, color: onBackground, fontFamily: "Poppins", fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontSize: 20, color: onBackground, fontFamily: "Poppins", fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, color: onBackground, fontFamily: "Poppins", fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 14, color: onBackground, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, color: onContainer, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    labelSmall: TextStyle(fontSize: 11, color: onContainer, fontFamily: "Poppins", fontWeight: FontWeight.w300),
  );
}