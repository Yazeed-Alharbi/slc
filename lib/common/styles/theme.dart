import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slc/common/styles/colors.dart';

final TextStyle commonSmallBodyTextStyle = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.normal,
);
final TextStyle commonSmallHeadlineTextStyle = GoogleFonts.poppins(
  fontSize: 18,
  fontWeight: FontWeight.w500,
);

final TextStyle commonMediumHeadlineTextStyle = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w700,
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
    headlineSmall: commonSmallHeadlineTextStyle.copyWith(
        color: const Color.fromARGB(130, 0, 0, 0)),
    headlineMedium: commonMediumHeadlineTextStyle.copyWith(
        color: const Color.fromARGB(255, 0, 0, 0)),
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
    headlineSmall: commonSmallHeadlineTextStyle.copyWith(
        color: const Color.fromARGB(130, 255, 255, 255)),
    headlineMedium: commonMediumHeadlineTextStyle.copyWith(
        color: const Color.fromARGB(255, 255, 255, 255)),
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
