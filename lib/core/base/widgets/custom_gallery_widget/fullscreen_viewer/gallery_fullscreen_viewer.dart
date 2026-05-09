import 'package:base_flutter/core/base/widgets/custom_gallery_widget/fullscreen_viewer/fullscreen_viewer_controller.dart';
import 'package:base_flutter/core/base/widgets/custom_gallery_widget/fullscreen_viewer/zoomable_image_viewer.dart';
import 'package:base_flutter/core/base/widgets/custom_gallery_widget/media_viewer.dart';
import 'package:flutter/material.dart';

class GalleryFullscreenViewer extends StatefulWidget {
  const GalleryFullscreenViewer({
    required this.items,
    super.key,
    this.initialIndex = 0,
    this.autoPlayVideos = true,
    this.loopVideos = true,
  });

  final List<GalleryMediaItem> items;
  final int initialIndex;
  final bool autoPlayVideos;
  final bool loopVideos;

  @override
  State<GalleryFullscreenViewer> createState() =>
      _GalleryFullscreenViewerState();
}

class _GalleryFullscreenViewerState extends State<GalleryFullscreenViewer> {
  late final PageController _pageController;
  late final FullscreenViewerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FullscreenViewerController(
      items: widget.items,
      initialIndex: widget.initialIndex,
    );
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        title: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Text(
            '${_controller.currentIndex + 1} / ${widget.items.length}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        onPageChanged: _controller.updateIndex,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          if (item.isVideo) {
            return const Center(
              child: Icon(Icons.play_arrow, color: Colors.white, size: 64),
            );
          }
          return ZoomableImageViewer(
            item: item,
            onDoubleTap: () {
              // Zoom logic implementation stub
            },
          );
        },
      ),
    );
  }
}
