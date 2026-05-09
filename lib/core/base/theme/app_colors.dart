import 'package:flutter/material.dart';

/// App Design System - Color Palette
///
/// A professional, scalable color system based on modern design standards.
/// Uses a Slate-based neutral palette and Indigo-based primary palette.
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY (Indigo)
  // ============================================
  static const Color primary50 = Color(0xFFEEF2FF);
  static const Color primary100 = Color(0xFFE0E7FF);
  static const Color primary200 = Color(0xFFC7D2FE);
  static const Color primary300 = Color(0xFFA5B4FC);
  static const Color primary400 = Color(0xFF818CF8);
  static const Color primary500 = Color(0xFF6366F1);
  static const Color primary600 = Color(0xFF4F46E5);
  static const Color primary700 = Color(0xFF4338CA);
  static const Color primary800 = Color(0xFF3730A3);
  static const Color primary900 = Color(0xFF312E81);

  static const Color primary = primary600;
  static const Color primaryDark = primary700;
  static const Color primaryLight = primary400;

  // ============================================
  // SECONDARY (Violet)
  // ============================================
  static const Color secondary50 = Color(0xFFF5F3FF);
  static const Color secondary500 = Color(0xFF8B5CF6);
  static const Color secondary600 = Color(0xFF7C3AED);

  static const Color secondary = secondary600;

  // ============================================
  // NEUTRALS (Slate)
  // ============================================
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  // Success (Emerald)
  static const Color success50 = Color(0xFFECFDF5);
  static const Color success500 = Color(0xFF10B981);
  static const Color success600 = Color(0xFF059669);
  static const Color success = success600;

  // Error (Rose)
  static const Color error50 = Color(0xFFFFF1F2);
  static const Color error500 = Color(0xFFF43F5E);
  static const Color error600 = Color(0xFFE11D48);
  static const Color error = error600;

  // Warning (Amber)
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning = warning600;

  // Info (Sky)
  static const Color info50 = Color(0xFFF0F9FF);
  static const Color info500 = Color(0xFF0EA5E9);
  static const Color info600 = Color(0xFF0284C7);
  static const Color info = info600;

  // ============================================
  // BACKGROUND & SURFACE (Light Mode)
  // ============================================
  static const Color backgroundLight = Color(0xFFF8FAFC); // slate50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ============================================
  // BACKGROUND & SURFACE (Dark Mode)
  // ============================================
  static const Color backgroundDark = Color(0xFF0F172A); // slate900
  static const Color surfaceDark = Color(0xFF1E293B); // slate800
  static const Color cardDark = Color(0xFF1E293B); // slate800

  // ============================================
  // TEXT COLORS
  // ============================================

  // Light Mode Text
  static const Color textPrimaryLight = Color(0xFF0F172A); // slate900
  static const Color textSecondaryLight = Color(0xFF475569); // slate600
  static const Color textTertiaryLight = Color(0xFF94A3B8); // slate400
  static const Color textDisabledLight = Color(0xFFCBD5E1); // slate300

  // Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // slate50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // slate400
  static const Color textTertiaryDark = Color(0xFF64748B); // slate500
  static const Color textDisabledDark = Color(0xFF334155); // slate700

  // ============================================
  // BORDER & DIVIDER
  // ============================================
  static const Color borderLight = Color(0xFFE2E8F0); // slate200
  static const Color borderDark = Color(0xFF334155); // slate700
  static const Color dividerLight = Color(0xFFF1F5F9); // slate100
  static const Color dividerDark = Color(0xFF1E293B); // slate800

  // ============================================
  // INPUT & INTERACTIVE
  // ============================================
  static const Color inputFillLight = Color(0xFFFFFFFF);
  static const Color inputFillDark = Color(0xFF0F172A);

  static const Color disabledLight = Color(0xFFF1F5F9);
  static const Color disabledDark = Color(0xFF1E293B);

  // ============================================
  // SHADOW
  // ============================================
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowDark = Color(0x3F000000);
}
