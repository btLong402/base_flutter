import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppInset {
  AppInset._();

  static const double extraSmall = 2;
  static const double small = 4;
  static const double medium = 8;
  static const double large = 16;
  static const double extraLarge = 24;
  static const double extraExtraLarge = 32;
  static const double extraExtraExtraLarge = 48;

  static const Gap gapSmall = Gap(4);
  static const Gap gapMedium = Gap(8);
  static const Gap gapLarge = Gap(16);
  static const Gap gapExtraLarge = Gap(24);
  static const Gap gapExtraExtraLarge = Gap(32);
  static const Gap gapExtraExtraExtraLarge = Gap(48);

  static Gap customGap(double size) => Gap(size);
}

extension SliverInset on Gap {
  SliverToBoxAdapter toSliver() => SliverToBoxAdapter(child: this);
}
