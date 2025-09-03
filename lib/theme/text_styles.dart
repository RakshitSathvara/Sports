import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static const _regular = FontWeight.w400;

  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 57.0),
    // Was headline1
    displayMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 45.0),
    // Was headline2
    displaySmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 36.0),
    // Was headline3
    headlineLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 32.0),
    // Was headline4
    headlineMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 28.0),
    // Was headline5
    headlineSmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 24.0),
    // Was headline6
    titleLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 22.0),
    // Was subtitle1
    titleMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    // Was subtitle2
    titleSmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    // New in Flutter 3.22.2
    bodyLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    // Was bodyText1
    bodyMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    // Was bodyText2
    bodySmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 12.0),
    // Was caption
    labelLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    // Was button
    labelMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 12.0),
    // New in Flutter 3.22.2
    labelSmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 11.0), // Was overline
  );
}
