import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OQDOThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData = themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  // Existing light theme colors
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color backgroundColor = Colors.white;
  static const Color greyColor = Color(0xFF2B2B2B);
  static const Color dividerColor = Color(0xFF006590);
  static const Color otherTextColor = Color(0xFF818181);
  static const Color filterDividerColor = Color(0xFFE3E3E3);
  static const Color dialogActionColor = Color(0xFF007AFF);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color offlineColor = Color(0xFFFF5F1F);
  static const Color onlineColor = Color(0xFF00A36C);
  static const Color chipColor = Color.fromRGBO(118, 115, 115, 1);
  static const Color buttonColor = Color(0xFF3C80A8);

  static const Color hobbiesListing = Color(0xFFEBF3F6);
  static const Color wellnessListing = Color(0xFFF7ECEC);
  static const Color sportsListing = Color(0xFFEBF4ED);

  // Dark theme equivalents
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkGreyColor = Color(0xFFE0E0E0);
  static const Color darkOtherTextColor = Color(0xFFB0B0B0);
  static const Color darkFilterDividerColor = Color(0xFF404040);
  static const Color darkChipColor = Color(0xFF404040);

  static const Color darkHobbiesListing = Color(0xFF2A3B3E);
  static const Color darkWellnessListing = Color(0xFF3E2A2A);
  static const Color darkSportsListing = Color(0xFF2A3E2F);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFF006590),
    primaryContainer: Color(0xFF117378),
    secondary: Color(0xFFEFF3F3),
    secondaryContainer: Color(0xFF006590),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFBFB),
    surfaceVariant: Color(0xFFF8F8F8),
    shadow: Color(0xFF818181),
    outline: Color(0xFFE0E0E0),
    onBackground: Color(0xFF1C1B1F),
    onSurface: Color(0xFF1C1B1F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF322942),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFF4FC3F7),
    primaryContainer: Color(0xFF00658F),
    secondary: Color(0xFF2A2A2A),
    secondaryContainer: Color(0xFF4FC3F7),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2A2A2A),
    shadow: Color(0xFF000000),
    outline: Color(0xFF404040),
    onBackground: Color(0xFFE6E1E5),
    onSurface: Color(0xFFE6E1E5),
    onPrimary: Color(0xFF003547),
    onSecondary: Color(0xFFE6E1E5),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    brightness: Brightness.dark,
  );

  // Text theme remains the same
  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 57.0),
    displayMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 45.0),
    displaySmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 36.0),
    headlineLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 32.0),
    headlineMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 28.0),
    headlineSmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 24.0),
    titleLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 22.0),
    titleMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    titleSmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    bodyLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    bodyMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    bodySmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 12.0),
    labelLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    labelMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 12.0),
    labelSmall: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 11.0),
  );

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex = '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }
}
