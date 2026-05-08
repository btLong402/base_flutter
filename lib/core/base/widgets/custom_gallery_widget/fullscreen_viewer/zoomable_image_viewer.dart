import 'package:flutter/material.dart';

import 'package:base_flutter/core/base/widgets/custom_gallery_widget/media_viewer.dart';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image_widget.dart';

class ZoomableImageViewer extends StatelessWidget {
  const ZoomableImageViewer({
    required this.item,
    super.key,
    this.onDoubleTap,
    this.zoomController,
  });

  final GalleryMediaItem item;
  final VoidCallback? onDoubleTap;
  final TransformationController? zoomController;

  @override
  Widget build(BuildContext context) {
    Widget child = CustomImageWidget(
      source: item.imageSource ?? item.thumbnailSource!,
      fit: BoxFit.contain,
      useShimmer: false,
      placeholder: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    if (item.heroTag != null) {
      child = Hero(tag: item.heroTag!, child: child);
    }

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: InteractiveViewer(
        transformationController: zoomController,
        minScale: 1,
        maxScale: 4,
        child: Center(child: child),
      ),
    );
  }
}
