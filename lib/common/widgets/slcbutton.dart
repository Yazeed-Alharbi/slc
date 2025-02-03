import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SLCButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double width;

  const SLCButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    this.width = double.infinity,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: Size(width, 45),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        overlayColor: backgroundColor.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
