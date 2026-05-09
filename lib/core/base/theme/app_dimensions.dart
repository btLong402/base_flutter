import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App Design System - Standard Dimensions and Spacing
///
/// Uses [ScreenUtil] for responsive scaling based on a 375x812 design.
class AppDimensions {
  AppDimensions._();

  // Design size from Figma/Design tool
  static const Size designSize = Size(375, 812);

  // Spacing Scale
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  // Vertical Spacing Scale
  static double get vxs => 4.h;
  static double get vsm => 8.h;
  static double get vmd => 16.h;
  static double get vlg => 24.h;
  static double get vxl => 32.h;

  // Radius Scale
  static double get rxs => 4.r;
  static double get rsm => 8.r;
  static double get rmd => 12.r;
  static double get rlg => 16.r;
  static double get rxl => 24.r;
  static double get rFull => 999.r;

  // Icon Sizes
  static double get iconXs => 12.r;
  static double get iconSm => 16.r;
  static double get iconMd => 24.r;
  static double get iconLg => 32.r;

  // Input & Button Heights
  static double get buttonHeight => 48.h;
  static double get inputHeight => 48.h;
  static double get compactInputHeight => 40.h;
}
