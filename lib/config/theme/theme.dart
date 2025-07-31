import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData agroNexusTheme = ThemeData(
  primarySwatch: Colors.green,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.green),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
    ),
    focusColor: Colors.green,
    floatingLabelBehavior: FloatingLabelBehavior.always,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      iconColor: Colors.white,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.only(top: 16, bottom: 16),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      iconColor: Colors.white,
      foregroundColor: Colors.green,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      iconColor: Colors.white,
      foregroundColor: Colors.green,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.poppins(fontSize: 20),
    bodyMedium: GoogleFonts.poppins(fontSize: 16),
    bodySmall: GoogleFonts.poppins(fontSize: 12),
    displayLarge: GoogleFonts.poppins(fontSize: 24),
    displayMedium: GoogleFonts.poppins(fontSize: 20),
    displaySmall: GoogleFonts.poppins(fontSize: 16),
    headlineLarge: GoogleFonts.poppins(fontSize: 24),
    headlineMedium: GoogleFonts.poppins(fontSize: 20),
    headlineSmall: GoogleFonts.poppins(fontSize: 16),
    labelLarge: GoogleFonts.poppins(fontSize: 24),
    labelMedium: GoogleFonts.poppins(fontSize: 20),
    labelSmall: GoogleFonts.poppins(fontSize: 16),
    titleLarge: GoogleFonts.poppins(fontSize: 24),
    titleMedium: GoogleFonts.poppins(fontSize: 20),
    titleSmall: GoogleFonts.poppins(fontSize: 16),
  ),
  dividerColor: Colors.transparent,
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    collapsedShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbVisibility: WidgetStateProperty.all(true),
    trackVisibility: WidgetStateProperty.all(true),
    interactive: true,
    radius: Radius.circular(8),
    thickness: WidgetStateProperty.all(8),
    thumbColor: WidgetStateProperty.all(Colors.green),
    trackColor: WidgetStateProperty.all(Colors.green[100]!),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.green[800]!,
    onPrimary: Colors.white,
    secondary: Colors.green,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
);
