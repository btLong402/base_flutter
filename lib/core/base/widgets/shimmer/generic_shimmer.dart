import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BoxShimmer extends StatelessWidget {
  const BoxShimmer({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key, this.hasAvatar = true});

  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.vmd,
      ),
      child: Row(
        children: [
          if (hasAvatar) ...[
            BoxShimmer(
              width: 48,
              height: 48,
              borderRadius: AppDimensions.rxl,
            ),
            Gap(AppDimensions.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxShimmer(width: 150, height: AppDimensions.vmd),
                Gap(AppDimensions.vsm),
                BoxShimmer(width: 100, height: AppDimensions.vsm + 4),
              ],
            ),
          ),
          BoxShimmer(width: 40, height: AppDimensions.vsm + 4),
        ],
      ),
    );
  }
}
