import 'package:flutter/material.dart';

class SLCIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final double size;
  final Border? border; // Add border parameter

  const SLCIconButton({
    Key? key,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    this.size = 30,
    this.border, // Make it optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total size based on icon size
    final buttonSize = size * 1.5;

    return ClipOval(
      // This clips both the visual AND the hit test area
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border, // Apply the border if provided
        ),
        child: Material(
          color: Colors.transparent, // Make Material transparent
          child: GestureDetector(
            onTap: onPressed,
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: size,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
