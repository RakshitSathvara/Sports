import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OQDOThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData = themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

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

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      primaryColor: const Color(0xFF030303),
      appBarTheme: AppBarTheme(backgroundColor: colorScheme.background, elevation: 0, iconTheme: IconThemeData(color: colorScheme.primary)),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFF006590),
    primaryContainer: Color(0xFF117378),
    secondary: Color(0xFFEFF3F3),
    secondaryContainer: Color(0xFF006590),
    background: Color(0xFFE6EBEB),
    surface: Color(0xFFFAFBFB),
    shadow: Color(0xff818181),
    onBackground: Colors.white,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
    surfaceVariant: Color(0xffF8F8F8),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFF006590),
    primaryContainer: Color(0xFF1CDEC9),
    secondary: Color(0xFF4D1F7C),
    secondaryContainer: Color(0xFF451B6F),
    background: Color(0xFF241E30),
    surface: Color(0xFF1F1929),
    shadow: Color(0xff818181),
    onBackground: Color(0x0DFFFFFF),
    // White with 0.05 opacity
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
    surfaceVariant: Color(0xffF8F8F8),
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
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
