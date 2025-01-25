import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slc/common/styles/colors.dart';

final TextStyle commonSmallBodyTextStyle = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.normal,
);

final TextStyle commonLargeTitleTextStyle = GoogleFonts.poppins(
  color: SLCColors.primaryColor,
  fontWeight: FontWeight.w700,
  fontSize: 28,
);

ThemeData lightMode = ThemeData(
    textTheme: TextTheme(
      bodySmall: commonSmallBodyTextStyle.copyWith(color: Colors.black),
      titleLarge: commonLargeTitleTextStyle,
    ),
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: Color.fromARGB(255, 251, 253, 255),
      surfaceTint: Color.fromARGB(255, 239, 242, 255),
    ));

ThemeData darkMode = ThemeData(
    textTheme: TextTheme(
      bodySmall: commonSmallBodyTextStyle.copyWith(color: Colors.white),
      titleLarge: commonLargeTitleTextStyle,
    ),
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: Color.fromARGB(255, 27, 27, 27),
      surfaceTint: Color.fromARGB(255, 40, 40, 40),
    ));
