import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';

import 'slcolorpickeritem.dart';

class SLCColorPicker extends StatefulWidget {
  final List<Color> colors = [
    SLCColors.navyBlue,
    SLCColors.tealGreen,
    SLCColors.cyan,
    SLCColors.lime,
    SLCColors.darkMaroon,
    SLCColors.deepViolet,
    SLCColors.electricBlue,
    SLCColors.neonPink,
    SLCColors.deepPurple,
    SLCColors.skyBlue,
    SLCColors.mutedRed,
    SLCColors.olive,
    SLCColors.sand,
    SLCColors.goldenYellow,
    SLCColors.sunsetOrange,
    SLCColors.deepSeaBlue,
    SLCColors.burntSienna
  ];
  final Function(Color) onColorSelected;

  SLCColorPicker({
    Key? key,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  _SLCColorPickerState createState() => _SLCColorPickerState();
}

class _SLCColorPickerState extends State<SLCColorPicker> {
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.colors.first; // Select the first color by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onColorSelected(selectedColor!); // Notify the parent widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.colors.map((color) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SLCColorPickerItem(
              color: color,
              isSelected: selectedColor == color,
              onTap: () {
                setState(() {
                  selectedColor = color;
                });
                widget.onColorSelected(color);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
