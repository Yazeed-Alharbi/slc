import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slc/common/styles/colors.dart';

class SLCButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double width;
  final Widget? icon;

  const SLCButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    this.width = double.infinity,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(width, 45),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        overlayColor: backgroundColor.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
