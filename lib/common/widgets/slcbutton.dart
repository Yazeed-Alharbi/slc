import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slc/common/styles/locale_theme_helper.dart';

class SLCButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double width;
  final double? height;
  final Widget? icon;
  final double? fontSize;
  final FontWeight? fontWeight;

  const SLCButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    this.width = double.infinity,
    this.height,
    this.icon,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current locale
    final locale = Localizations.localeOf(context).languageCode;

    // Create a basic text style with properties from this widget
    final baseTextStyle = TextStyle(
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize ?? 16,
    );

    // Get the appropriate font based on locale
    final textStyle = locale == 'ar'
        ? GoogleFonts.rubik(
            fontWeight: fontWeight ?? FontWeight.bold,
            fontSize: fontSize ?? 16,
          )
        : GoogleFonts.poppins(
            fontWeight: fontWeight ?? FontWeight.bold,
            fontSize: fontSize ?? 16,
          );

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(width, height ?? 45),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        overlayColor: Colors.transparent,
        shadowColor: Colors.transparent,
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
            style: textStyle, // Use the locale-aware text style
          ),
        ],
      ),
    );
  }
}
