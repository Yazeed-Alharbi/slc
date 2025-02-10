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
  scaffoldBackgroundColor: Color(0xFFF9F9F9),
  textTheme: TextTheme(
    bodySmall: commonSmallBodyTextStyle.copyWith(color: Colors.black),
    titleLarge: commonLargeTitleTextStyle,
  ),
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: SLCColors.primaryColor,
    surface: Color.fromARGB(255, 255, 255, 255),
    surfaceTint: Color.fromARGB(255, 239, 242, 255),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      disabledBackgroundColor: SLCColors.disabledColor,
    ),
  ),
);

ThemeData darkMode = ThemeData(
  scaffoldBackgroundColor: Color.fromARGB(255, 23, 23, 23),
  textTheme: TextTheme(
    bodySmall: commonSmallBodyTextStyle.copyWith(color: Colors.white),
    titleLarge: commonLargeTitleTextStyle,
  ),
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: SLCColors.primaryColor,
    surface: Color.fromARGB(255, 12, 12, 12),
    surfaceTint: Color.fromARGB(255, 41, 41, 41),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      disabledBackgroundColor: const Color.fromARGB(255, 58, 58, 58),
    ),
  ),
);
