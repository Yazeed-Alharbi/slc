import 'package:flutter/material.dart';

class SLCIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final double size;

  const SLCIconButton({
    Key? key,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    this.size = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const CircleBorder(),
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.all(5),
      ),
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor,
        size: size,
      ),
    );
  }
}
