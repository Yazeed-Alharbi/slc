import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcolorpickeritem.dart';

class SLCColorPicker extends StatefulWidget {
  final List<Color> colors;
  final Function(Color) onColorSelected;

  const SLCColorPicker({
    Key? key,
    required this.colors,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  _SLCColorPickerState createState() => _SLCColorPickerState();
}

class _SLCColorPickerState extends State<SLCColorPicker> {
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.colors.map((color) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
