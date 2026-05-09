import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Design System - Typography
///
/// Uses the 'Inter' font family with a professional type scale.
/// All font sizes use [ScreenUtil]'s `.sp` for responsiveness.
///
/// Note: Styles are defined as getters to ensure [ScreenUtil] values
/// are correctly applied at runtime.
class AppTextStyles {
  AppTextStyles._();

  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  static TextStyle get _baseTextStyle => GoogleFonts.inter(
    color: AppColors.textPrimaryLight,
    height: 1.2,
  );

  // =========================================================================
  // DISPLAY STYLES
  // =========================================================================

  static TextStyle get displayLarge => _baseTextStyle.copyWith(
    fontSize: 57.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
    fontSize: 45.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
    fontSize: 36.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // =========================================================================
  // HEADLINE STYLES
  // =========================================================================

  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
    fontSize: 32.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
    fontSize: 28.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  // =========================================================================
  // TITLE STYLES
  // =========================================================================

  static TextStyle get titleLarge => _baseTextStyle.copyWith(
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // =========================================================================
  // BODY STYLES
  // =========================================================================

  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // =========================================================================
  // LABEL STYLES
  // =========================================================================

  static TextStyle get labelLarge => _baseTextStyle.copyWith(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // =========================================================================
  // CUSTOM UI STYLES
  // =========================================================================

  static TextStyle get buttonLarge => labelLarge.copyWith(fontSize: 16.sp);
  static TextStyle get buttonMedium => labelLarge;
  static TextStyle get buttonSmall => labelMedium;
}
