import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'slcolorpickeritem.dart';

class SLCColorPicker extends StatefulWidget {
  final List<CourseColor> colors = SLCColors.courseColorMap.keys.toList();
  final Function(CourseColor) onColorSelected;
  final CourseColor? initialColor; // Add this parameter

  SLCColorPicker({
    Key? key,
    required this.onColorSelected,
    this.initialColor, // Add this parameter
  }) : super(key: key);

  @override
  _SLCColorPickerState createState() => _SLCColorPickerState();
}

class _SLCColorPickerState extends State<SLCColorPicker> {
  CourseColor? selectedColor;

  @override
  void initState() {
    super.initState();
    // Use initialColor if provided, otherwise use the first color
    selectedColor = widget.initialColor ?? widget.colors.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onColorSelected(selectedColor!); // Notify the parent widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.colors.map((courseColor) {
          Color colorValue =
              SLCColors.getCourseColor(courseColor); // Get actual color

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SLCColorPickerItem(
              color: colorValue,
              isSelected: selectedColor == courseColor,
              onTap: () {
                setState(() {
                  selectedColor = courseColor;
                });
                widget.onColorSelected(courseColor); // Return `CourseColor`
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}