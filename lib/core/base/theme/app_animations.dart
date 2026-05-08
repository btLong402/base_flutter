import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration staggered = Duration(milliseconds: 375);
  static const Duration celebration = Duration(milliseconds: 1500);

  // Curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve softCurve = Curves.easeInOutSine;
  static const Curve premiumSpring = Curves.easeOutBack;

  // Animation values
  static const double hoverScale = 1.02;
  static const double activeScale = 0.95;
}
