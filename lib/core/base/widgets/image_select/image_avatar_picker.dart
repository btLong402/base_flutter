import 'dart:io';

import 'package:base_flutter/core/base/widgets/avatar/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAvatarPicker extends StatefulWidget {
  const ImageAvatarPicker({
    required this.onImageSelected,
    super.key,
    this.networkUrl, // Keep for backward compatibility
    this.initialUrl,
    this.size = 100,
  });

  final String? initialUrl;
  final String? networkUrl;
  final void Function(File) onImageSelected;
  final double size;

  @override
  State<ImageAvatarPicker> createState() => _ImageAvatarPickerState();
}

class _ImageAvatarPickerState extends State<ImageAvatarPicker> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _selectedImage = file);
      widget.onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_selectedImage != null)
          CircleAvatar(
            radius: widget.size / 2,
            backgroundImage: FileImage(_selectedImage!),
          )
        else
          AppAvatar(
            url: widget.initialUrl ?? widget.networkUrl,
            size: widget.size,
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
