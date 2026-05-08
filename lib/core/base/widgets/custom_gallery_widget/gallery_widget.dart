import 'package:flutter/material.dart';

import 'package:base_flutter/core/base/widgets/custom_gallery_widget/animation_utils.dart';
import 'package:base_flutter/core/base/widgets/custom_gallery_widget/fullscreen_viewer/gallery_fullscreen_viewer.dart';
import 'package:base_flutter/core/base/widgets/custom_gallery_widget/media_viewer.dart';
import 'package:base_flutter/core/base/widgets/custom_gallery_widget/thumbnail_grid.dart';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image_widget.dart';

/// Public entry point that exposes a gallery capable of grid or
/// carousel layout.
class CustomGalleryWidget extends StatefulWidget {
  const CustomGalleryWidget({
    required this.items,
    super.key,
    this.mode = GalleryDisplayMode.grid,
    this.initialIndex = 0,
    this.onMediaTap,
    this.enableFullscreen = true,
    this.gridCrossAxisCount = 3,
    this.gridSpacing = 4,
    this.gridPadding = const EdgeInsets.all(8),
    this.carouselHeight = 240,
    this.showCarouselIndicator = true,
    this.autoPlayVideos = true,
    this.loopVideos = true,
  });

  final List<GalleryMediaItem> items;
  final GalleryDisplayMode mode;
  final int initialIndex;
  final ValueChanged<int>? onMediaTap;
  final bool enableFullscreen;
  final int gridCrossAxisCount;
  final double gridSpacing;
  final EdgeInsetsGeometry gridPadding;
  final double carouselHeight;
  final bool showCarouselIndicator;
  final bool autoPlayVideos;
  final bool loopVideos;

  @override
  State<CustomGalleryWidget> createState() => _CustomGalleryWidgetState();
}

class _CustomGalleryWidgetState extends State<CustomGalleryWidget> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPage = ValueNotifier<int>(widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (widget.mode) {
      case GalleryDisplayMode.grid:
        return GalleryThumbnailGrid(
          items: widget.items,
          onItemTap: _handleItemTap,
          crossAxisCount: widget.gridCrossAxisCount,
          spacing: widget.gridSpacing,
          padding: widget.gridPadding,
        );
      case GalleryDisplayMode.carousel:
        return _buildCarousel(context);
    }
  }

  Widget _buildCarousel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.carouselHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) => _currentPage.value = index,
            itemBuilder: (context, index) => _CarouselMediaTile(
              item: widget.items[index],
              onTap: () => _handleItemTap(index),
            ),
          ),
        ),
        if (widget.showCarouselIndicator && widget.items.length > 1)
          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, index, _) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (dotIndex) {
                  final isActive = index == dotIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: isActive ? 16 : 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleItemTap(int index) async {
    widget.onMediaTap?.call(index);
    if (!widget.enableFullscreen) {
      return;
    }

    await Navigator.of(context).push(
      buildGalleryPageRoute<void>(
        builder: (context) => GalleryFullscreenViewer(
          items: widget.items,
          initialIndex: index,
          autoPlayVideos: widget.autoPlayVideos,
          loopVideos: widget.loopVideos,
        ),
      ),
    );
  }
}

class _CarouselMediaTile extends StatelessWidget {
  const _CarouselMediaTile({required this.item, required this.onTap});

  final GalleryMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (item.type == GalleryMediaType.video) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          if (item.thumbnailSource != null)
            CustomImageWidget(
              source: item.thumbnailSource!,
              placeholder: const _CarouselPlaceholder(),
            )
          else
            const _CarouselPlaceholder(),
          const Align(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      content = CustomImageWidget(
        source: item.imageSource ?? item.thumbnailSource!,
        placeholder: const _CarouselPlaceholder(),
      );
    }

    if (item.heroTag != null) {
      content = Hero(tag: item.heroTag!, child: content);
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: content),
    );
  }
}

class _CarouselPlaceholder extends StatelessWidget {
  const _CarouselPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF1F1F1F),
      child: Center(child: Icon(Icons.photo, color: Colors.white38, size: 36)),
    );
  }
}
