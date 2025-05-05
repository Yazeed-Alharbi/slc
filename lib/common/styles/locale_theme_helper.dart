import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Returns the appropriate text style based on the current locale
TextStyle getLocalizedTextStyle({
  required BuildContext context,
  required TextStyle defaultStyle,
  String? englishFontFamily,
}) {
  // Get the current locale
  final locale = Localizations.localeOf(context).languageCode;

  // Use Arabic font for Arabic locale, otherwise use the default
  if (locale == 'ar') {
    return GoogleFonts.getFont(
      "Rubik",
      textStyle: defaultStyle,
    );
  }

  // For English or other languages, use the specified English font or default
  if (englishFontFamily != null) {
    return GoogleFonts.poppins(
      textStyle: defaultStyle,
    );
  }

  // Return the default style if no English font specified
  return defaultStyle;
}
