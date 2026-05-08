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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasAvatar) ...[
            const BoxShimmer(width: 48, height: 48, borderRadius: 24),
            const Gap(12),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxShimmer(width: 150, height: 16),
                Gap(8),
                BoxShimmer(width: 100, height: 12),
              ],
            ),
          ),
          const BoxShimmer(width: 40, height: 12),
        ],
      ),
    );
  }
}
