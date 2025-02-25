import 'package:flutter/material.dart';

/// All colors, including course and non-course colors.
class SLCColors {
  static const Color primaryColor = Color(0xFF4F00FF);
  static const Color disabledColor = Color.fromARGB(255, 205, 205, 224);
  static const Color darkDisabledColor = Color.fromARGB(255, 4, 4, 4);

  static const Color electricBlue = Color(0xFF1A73E8);
  static const Color deepPurple = Color(0xFF673AB7);
  static const Color neonPink = Color(0xFFFF2D55);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color lime = Color(0xFFCDDC39);

  static const Color pastelBlue = Color(0xFFAEC6CF);
  static const Color pastelGreen = Color(0xFF77DD77);
  static const Color pastelPink = Color(0xFFFDBCB4);
  static const Color pastelPurple = Color(0xFFCBAACB);

  static const Color navyBlue = Color(0xFF00239F);
  static const Color tealGreen = Color(0xFF009F83);
  static const Color mutedRed = Color(0xFFB06164);
  static const Color olive = Color(0xFF979A28);
  static const Color skyBlue = Color(0xFF618CAF);
  static const Color darkMaroon = Color(0xFF560015);
  static const Color slateGray = Color(0xFF8E909F);
  static const Color sand = Color(0xFFCFC099);
  static const Color brightCyan = Color(0xFF7ED3F4);
  static const Color forestGreen = Color(0xFF3B6919);
  static const Color deepViolet = Color(0xFF4D0084);

  static const Color sunsetOrange = Color(0xFFFF4500);
  static const Color goldenYellow = Color.fromARGB(255, 255, 191, 0);
  static const Color deepSeaBlue = Color(0xFF005F6B);
  static const Color richBurgundy = Color(0xFF800020);
  static const Color mossGreen = Color(0xFF8A9A5B);
  static const Color dustyRose = Color(0xFFDCAE96);
  static const Color coolGray = Color(0xFF8C92AC);
  static const Color midnightBlue = Color(0xFF191970);
  static const Color pearlWhite = Color(0xFFFFF5EE);
  static const Color charcoalBlack = Color(0xFF333333);
  static const Color burntSienna = Color(0xFFE97451);
  static const Color arcticBlue = Color(0xFF68A0B0);

  static const Color red = Color(0xFFFF0000);
  static const Color orange = Color(0xFFFF8C00);
  static const Color purple = Color(0xFF800080);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color green = Color(0xFF008000);

  /// 🎨 **Course Colors Only (Subset of SLCColors)**
  static const Map<CourseColor, Color> courseColorMap = {
    CourseColor.navyBlue: navyBlue,
    CourseColor.tealGreen: tealGreen,
    CourseColor.cyan: cyan,
    CourseColor.lime: lime,
    CourseColor.darkMaroon: darkMaroon,
    CourseColor.deepViolet: deepViolet,
    CourseColor.electricBlue: electricBlue,
    CourseColor.neonPink: neonPink,
    CourseColor.deepPurple: deepPurple,
    CourseColor.skyBlue: skyBlue,
    CourseColor.mutedRed: mutedRed,
    CourseColor.olive: olive,
    CourseColor.sand: sand,
    CourseColor.goldenYellow: goldenYellow,
    CourseColor.sunsetOrange: sunsetOrange,
    CourseColor.deepSeaBlue: deepSeaBlue,
    CourseColor.burntSienna: burntSienna,
  };

  /// Get color from `CourseColor` enum
  static Color getCourseColor(CourseColor color) {
    return courseColorMap[color] ?? navyBlue; 
  }

  /// Convert a string (e.g., `"navyBlue"`) to `CourseColor` enum
  static CourseColor getCourseColorFromString(String colorName) {
    return CourseColor.values.firstWhere(
      (e) => e.name == colorName,
      orElse: () => CourseColor.navyBlue, // Default color
    );
  }
}

/// **Enum for Course Colors (Only Colors Used in Courses)**
enum CourseColor {
  navyBlue,
  tealGreen,
  cyan,
  lime,
  darkMaroon,
  deepViolet,
  electricBlue,
  neonPink,
  deepPurple,
  skyBlue,
  mutedRed,
  olive,
  sand,
  goldenYellow,
  sunsetOrange,
  deepSeaBlue,
  burntSienna,
}
