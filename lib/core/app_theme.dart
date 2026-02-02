import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Midnight Meadow theme — prismic dark, nature-inspired, premium feel.
/// Background: #0F1412 | Surface: #182118 | Primary: #5B9A7A | Accent: #8BC4A8
abstract class AppTheme {
  // Core palette — Midnight Meadow
  static const Color background = Color(0xFF0F1412);
  static const Color surface = Color(0xFF182118);
  static const Color surfaceVariant = Color(0xFF1E2A22);
  static const Color primary = Color(0xFF5B9A7A);
  static const Color accent = Color(0xFF8BC4A8);
  static const Color onSurfaceMuted = Color(0xFFA8B8AE);
  static const Color onSurfaceSubtle = Color(0xFF6B7D72);

  // Premium layout tokens
  static const double radiusSm = 12;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double radiusXl = 36;

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: Color(0xFFCF6679),
      onPrimary: background,
      onSecondary: background,
      onSurface: Color(0xFFE8EDEA),
      onError: Colors.black,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFFE8EDEA)),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),
  );
}
