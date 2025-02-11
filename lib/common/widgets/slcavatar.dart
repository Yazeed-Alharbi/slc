import 'package:flutter/material.dart';

class SLCAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;
  final String defaultImage;

  const SLCAvatar({
    Key? key,
    this.imageUrl,
    this.size = 80.0,
    this.radius = 15.0,
    this.defaultImage = "assets/DefaultProfileImage.jpg",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = imageUrl != null && imageUrl!.startsWith("http");

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: isNetworkImage
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                defaultImage,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              imageUrl ?? defaultImage,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
    );
  }
}
