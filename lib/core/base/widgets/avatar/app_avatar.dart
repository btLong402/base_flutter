import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image.dart';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    this.size,
    this.borderColor,
    this.onTap,
  });

  final String? url;
  final double? size;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? 40.r;

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2.r)
            : null,
      ),
      child: url != null
          ? CustomImageWidget(
              source: CustomImageSource.network(url!),
              width: avatarSize,
              height: avatarSize,
              borderRadius: BorderRadius.circular(avatarSize / 2),
            )
          : Icon(Icons.person, color: Colors.white, size: avatarSize * 0.6),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}
