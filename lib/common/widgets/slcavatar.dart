import 'package:flutter/material.dart';
import 'dart:io';

class SLCAvatar extends StatelessWidget {
  final String? imageUrl;
  final FileImage? imageFile; // Kept as FileImage
  final double size;
  final double radius;
  final Color? placeholderColor;
  final String defaultImage;

  const SLCAvatar({
    Key? key,
    this.imageUrl,
    this.imageFile,
    this.size = 80.0,
    this.radius = 15.0,
    this.placeholderColor,
    this.defaultImage = "assets/DefaultProfileImage.jpg",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    // Priority: FileImage > Network > Asset
    if (imageFile != null) {
      return Image(
        image: imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    } else if (imageUrl != null && imageUrl!.startsWith("http")) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      color: placeholderColor ?? Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: size / 3,
          height: size / 3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      imageUrl != null && !imageUrl!.startsWith("http")
          ? imageUrl!
          : defaultImage,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
