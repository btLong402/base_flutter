import 'package:flutter/material.dart';
import 'package:base_flutter/core/base/widgets/custom_gallery_widget/media_viewer.dart';

class FullscreenViewerController extends ChangeNotifier {
  FullscreenViewerController({
    required this.items,
    this.initialIndex = 0,
  }) : _currentIndex = initialIndex;

  final List<GalleryMediaItem> items;
  final int initialIndex;

  int _currentIndex;
  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  // Placeholder for video initialization logic that was likely here
  void initializeVideo(int index) {
    final item = items[index];
    if (item.isVideo) {
      final source = item.videoSource;
      if (source is NetworkGalleryVideoSource) {
        // Use source.url, source.cacheManager, source.headers
      } else if (source is AssetGalleryVideoSource) {
        // Use source.assetPath, source.package
      } else if (source is FileGalleryVideoSource) {
        // Use source.file
      }
    }
  }
}

class TransformationControllerManager extends ChangeNotifier {
  final TransformationController controller = TransformationController();

  void reset() {
    controller.value = Matrix4.identity();
    notifyListeners();
  }

  void zoomTo(Offset position) {
    // Zoom logic
  }
}
