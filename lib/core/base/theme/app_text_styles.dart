import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text styles
class AppTextStyles {
  AppTextStyles._();

  static String? get fontFamily => GoogleFonts.poppins().fontFamily;

  // Base text style
  static TextStyle get _baseTextStyle => TextStyle(
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontWeight: FontWeight.normal,
  );

  // =========================================================================
  // DISPLAY TEXT STYLES (Largest)
  // =========================================================================

  static TextStyle displayLarge = _baseTextStyle.copyWith(
    fontSize: 62,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium = _baseTextStyle.copyWith(
    fontSize: 50,
    fontWeight: FontWeight.w400,
  );

  static TextStyle displaySmall = _baseTextStyle.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w400,
  );

  // =========================================================================
  // HEADLINE TEXT STYLES
  // =========================================================================

  static TextStyle headlineLarge = _baseTextStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  static TextStyle headlineMedium = _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w400,
  );

  static TextStyle headlineSmall = _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );

  // =========================================================================
  // TITLE TEXT STYLES
  // =========================================================================

  static TextStyle titleLarge = _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleMedium = _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // =========================================================================
  // LABEL TEXT STYLES
  // =========================================================================

  static TextStyle labelLarge = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = _baseTextStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // =========================================================================
  // BODY TEXT STYLES
  // =========================================================================

  static TextStyle bodyLarge = _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle bodyMedium = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // =========================================================================
  // CUSTOM TEXT STYLES
  // =========================================================================

  static TextStyle buttonLarge = _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle buttonMedium = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle buttonSmall = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle caption = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static TextStyle overline = _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
}
