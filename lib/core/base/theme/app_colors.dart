import 'package:flutter/material.dart';

/// ChatOps Design System - Color Palette
///
/// Based on DESIGN_SYSTEM.md specifications.
/// Primary Blue: #1A56DB
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY PALETTE - Từ UI Screenshots
  // ============================================

  /// Primary Blue - Main CTA
  /// Used for: Header badges, Primary buttons
  static const Color primary = Color(0xFF1A56DB);

  /// Primary Dark - Darker variant
  static const Color primaryDark = Color(0xFF1E40AF);

  /// Primary Light - Lighter variant
  static const Color primaryLight = Color(0xFF3B82F6);

  /// Light Blue - Background variant
  /// Used for: Card backgrounds, Sections
  static const Color primaryBackground = Color(0xFFEBF5FF);

  /// Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  /// Premium Indigo Gradient for Calm Productivity Identity
  static const LinearGradient premiumIndigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1), // Indigo Light
      Color(0xFF4F46E5), // Indigo Primary
      Color(0xFF3730A3), // Indigo Dark
    ],
  );

  // ============================================
  // SECONDARY COLORS
  // ============================================

  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF34D399);

  // ============================================
  // CHAT BUBBLE COLORS
  // ============================================

  /// My Message - Blue (góc phải)
  static const Color myMessageLight = Color(0xFF1A56DB);
  static const Color myMessageDark = Color(0xFF3B82F6);

  /// Their Message - Gray (góc trái)
  static const Color theirMessageLight = Color(0xFFF3F4F6);
  static const Color theirMessageDark = Color(0xFF374151);

  /// System Message - Light blue
  static const Color systemMessageLight = Color(0xFFEBF5FF);
  static const Color systemMessageDark = Color(0xFF1E3A5F);

  /// Alert Message - Amber
  static const Color alertMessageLight = Color(0xFFFEF3C7);
  static const Color alertMessageDark = Color(0xFF78350F);

  // ============================================
  // STATUS INDICATOR COLORS
  // ============================================

  /// Đang chờ - Amber
  static const Color statusPending = Color(0xFFF59E0B);

  /// Đang chạy - Blue
  static const Color statusInProgress = Color(0xFF3B82F6);

  /// Chờ thu tiền - Orange
  static const Color statusAwaitingPayment = Color(0xFFF97316);

  /// Hoàn thành - Green
  static const Color statusCompleted = Color(0xFF22C55E);

  /// Hủy - Red
  static const Color statusCancelled = Color(0xFFEF4444);

  /// Online - Green
  static const Color statusOnline = Color(0xFF22C55E);

  /// Offline - Gray
  static const Color statusOffline = Color(0xFF9CA3AF);

  // Status aliases for convenience
  static const Color statusActive = statusInProgress;
  static const Color statusSuccess = statusCompleted;
  static const Color statusWarning = statusAwaitingPayment;
  static const Color statusError = statusCancelled;

  // ============================================
  // SEMANTIC COLORS - Financial
  // ============================================

  /// Thu vào (xanh lá)
  static const Color income = Color(0xFF22C55E);

  /// Chi ra (đỏ)
  static const Color expense = Color(0xFFEF4444);

  /// Còn nợ (cam)
  static const Color debt = Color(0xFFF97316);

  /// Lợi nhuận (emerald)
  static const Color profit = Color(0xFF10B981);

  // ============================================
  // ROLE COLORS
  // ============================================

  /// Quản lý (tím)
  static const Color roleAdmin = Color(0xFF8B5CF6);

  /// Tài xế (xanh)
  static const Color roleDriver = Color(0xFF3B82F6);

  /// Bốc xếp (vàng)
  static const Color roleWorker = Color(0xFFF59E0B);

  /// Sales (hồng)
  static const Color roleSales = Color(0xFFEC4899);

  // ============================================
  // GENERAL SEMANTIC COLORS
  // ============================================

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ============================================
  // BACKGROUND COLORS (Light)
  // ============================================

  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surface = surfaceLight;

  // ============================================
  // BACKGROUND COLORS (Dark)
  // ============================================

  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color cardDark = Color(0xFF374151);

  // ============================================
  // TEXT COLORS (Light)
  // ============================================

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textDisabledLight = Color(0xFF9CA3AF);
  static const Color textSecondary = textSecondaryLight;

  // ============================================
  // TEXT COLORS (Dark)
  // ============================================

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textDisabledDark = Color(0xFF6B7280);

  // ============================================
  // DIVIDER & BORDER
  // ============================================

  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF4B5563);
  static const Color glassBorder = Color(0xFFFFFFFF);

  // ============================================
  // INPUT
  // ============================================

  static const Color inputFillLight = Color(0xFFF3F4F6);
  static const Color inputFillDark = Color(0xFF374151);
  static const Color hint = Color(0xFF9CA3AF);
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color border = Color(0xFFE5E7EB);

  // ============================================
  // SHADOW
  // ============================================

  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x5FFFFFFF);
}
