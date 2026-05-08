import 'package:flutter/material.dart';

import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image.dart';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image_widget.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    this.size = 40,
    this.borderColor,
    this.onTap,
  });

  final String? url;
  final double size;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
        gradient: url == null ? AppColors.primaryGradient : null,
      ),
      child: url != null
          ? CustomImageWidget(
              source: CustomImageSource.network(url!),
              width: size,
              height: size,
              borderRadius: BorderRadius.circular(size / 2),
            )
          : Icon(Icons.person, color: Colors.white, size: size * 0.6),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}
