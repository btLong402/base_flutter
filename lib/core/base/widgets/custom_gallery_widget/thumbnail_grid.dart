import 'package:base_flutter/core/base/widgets/custom_gallery_widget/media_viewer.dart';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image_widget.dart';
import 'package:flutter/material.dart';

class GalleryThumbnailGrid extends StatelessWidget {
  const GalleryThumbnailGrid({
    required this.items,
    required this.onItemTap,
    super.key,
    this.crossAxisCount = 3,
    this.spacing = 4,
    this.padding = EdgeInsets.zero,
  });

  final List<GalleryMediaItem> items;
  final ValueChanged<int> onItemTap;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        Widget content = CustomImageWidget(
          source: item.thumbnailSource ?? item.imageSource!,
        );

        if (item.heroTag != null) {
          content = Hero(tag: item.heroTag!, child: content);
        }

        return GestureDetector(
          onTap: () => onItemTap(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              content,
              if (item.isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
