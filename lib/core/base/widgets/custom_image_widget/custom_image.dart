import 'dart:io';

enum CustomImageSourceType { network, asset, file }

class CustomImageSource {
  const CustomImageSource({
    required this.type,
    required this.path,
    this.file,
  });

  factory CustomImageSource.network(String url) => CustomImageSource(
    type: CustomImageSourceType.network,
    path: url,
  );

  factory CustomImageSource.asset(String path) => CustomImageSource(
    type: CustomImageSourceType.asset,
    path: path,
  );

  factory CustomImageSource.file(File file) => CustomImageSource(
    type: CustomImageSourceType.file,
    path: file.path,
    file: file,
  );

  final CustomImageSourceType type;
  final String path;
  final File? file;
}
