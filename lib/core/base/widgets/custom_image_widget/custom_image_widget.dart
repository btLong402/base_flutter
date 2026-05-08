import 'package:base_flutter/core/base/widgets/custom_image_widget/cache_manager.dart';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    required this.source,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.useShimmer = true,
  });

  final CustomImageSource source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useShimmer;

  @override
  Widget build(BuildContext context) {
    Widget image;

    switch (source.type) {
      case CustomImageSourceType.network:
        image = CachedNetworkImage(
          imageUrl: source.path,
          width: width,
          height: height,
          fit: fit,
          cacheManager: CustomImageCacheManager.instance,
          placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
          errorWidget: (context, url, error) => errorWidget ?? _buildError(),
        );
      case CustomImageSourceType.asset:
        image = Image.asset(
          source.path,
          width: width,
          height: height,
          fit: fit,
        );
      case CustomImageSourceType.file:
        if (source.file != null) {
          image = Image.file(
            source.file!,
            width: width,
            height: height,
            fit: fit,
          );
        } else {
          image = _buildError();
        }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    if (!useShimmer) {
      return const Center(child: CircularProgressIndicator());
    }
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
  }
}
