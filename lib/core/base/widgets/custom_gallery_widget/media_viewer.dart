import 'dart:io';
import 'package:base_flutter/core/base/widgets/custom_image_widget/custom_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum GalleryMediaType { image, video }

enum GalleryDisplayMode { grid, carousel }

class GalleryMediaItem {
  const GalleryMediaItem({
    required this.type,
    this.imageSource,
    this.thumbnailSource,
    this.videoSource,
    this.heroTag,
    this.metadata = const {},
  });
  factory GalleryMediaItem.video({
    required GalleryVideoSource videoSource,
    CustomImageSource? thumbnailSource,
    String? heroTag,
    Map<String, dynamic> metadata = const {},
  }) {
    return GalleryMediaItem(
      type: GalleryMediaType.video,
      videoSource: videoSource,
      thumbnailSource: thumbnailSource,
      heroTag: heroTag,
      metadata: metadata,
    );
  }

  factory GalleryMediaItem.image({
    required CustomImageSource imageSource,
    CustomImageSource? thumbnailSource,
    String? heroTag,
    Map<String, dynamic> metadata = const {},
  }) {
    return GalleryMediaItem(
      type: GalleryMediaType.image,
      imageSource: imageSource,
      thumbnailSource: thumbnailSource ?? imageSource,
      heroTag: heroTag,
      metadata: metadata,
    );
  }

  final GalleryMediaType type;
  final CustomImageSource? imageSource;
  final CustomImageSource? thumbnailSource;
  final GalleryVideoSource? videoSource;
  final String? heroTag;
  final Map<String, dynamic> metadata;

  bool get isVideo => type == GalleryMediaType.video;
  bool get isImage => type == GalleryMediaType.image;
}

abstract class GalleryVideoSource {
  const GalleryVideoSource();

  factory GalleryVideoSource.network(
    String url, {
    BaseCacheManager? cacheManager,
    Map<String, String>? headers,
  }) = NetworkGalleryVideoSource;

  factory GalleryVideoSource.asset(String assetPath, {String? package}) =
      AssetGalleryVideoSource;

  factory GalleryVideoSource.file(File file) = FileGalleryVideoSource;
}

class NetworkGalleryVideoSource extends GalleryVideoSource {
  const NetworkGalleryVideoSource(this.url, {this.cacheManager, this.headers});

  final String url;
  final BaseCacheManager? cacheManager;
  final Map<String, String>? headers;
}

class AssetGalleryVideoSource extends GalleryVideoSource {
  const AssetGalleryVideoSource(this.assetPath, {this.package});

  final String assetPath;
  final String? package;
}

class FileGalleryVideoSource extends GalleryVideoSource {
  const FileGalleryVideoSource(this.file);

  final File file;
}

class GalleryCacheManager {
  static const String key = 'galleryCacheKey';
  static final CacheManager instance = CacheManager(
    Config(key, stalePeriod: const Duration(days: 7), maxNrOfCacheObjects: 100),
  );
}
