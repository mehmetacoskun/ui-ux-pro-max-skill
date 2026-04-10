import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color jqPrimaryRed = Color(0xFFCF4520);
  static const Color jqBlack = Color(0xFF000000);
  static const Color jqWhite = Color(0xFFFFFFFF);
  static const Color jqGray = Color(0xFFE5E5E5);
  static const Color jqDarkBg = Color(0xFF121212);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: jqBlack,
    scaffoldBackgroundColor: jqWhite,
    colorScheme: ColorScheme.light(
      primary: jqBlack,
      secondary: jqPrimaryRed,
      surface: jqWhite,
      onPrimary: jqWhite,
      onSecondary: jqWhite,
      onSurface: jqBlack,
    ),
    textTheme: GoogleFonts.nunitoSansTextTheme().copyWith(
      displayLarge: GoogleFonts.rubik(fontWeight: FontWeight.bold, color: jqBlack),
      headlineMedium: GoogleFonts.rubik(fontWeight: FontWeight.bold, color: jqBlack),
      titleLarge: GoogleFonts.rubik(fontWeight: FontWeight.w600, color: jqBlack),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: jqWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: jqWhite,
    scaffoldBackgroundColor: jqDarkBg,
    colorScheme: ColorScheme.dark(
      primary: jqWhite,
      secondary: jqPrimaryRed,
      surface: const Color(0xFF1E1E1E),
      onPrimary: jqBlack,
      onSecondary: jqWhite,
      onSurface: jqWhite,
    ),
    textTheme: GoogleFonts.nunitoSansTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.rubik(fontWeight: FontWeight.bold, color: jqWhite),
      headlineMedium: GoogleFonts.rubik(fontWeight: FontWeight.bold, color: jqWhite),
      titleLarge: GoogleFonts.rubik(fontWeight: FontWeight.w600, color: jqWhite),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: jqDarkBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
