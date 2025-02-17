import 'package:flutter/material.dart';
import 'slcdaypickeritem.dart';

class SLCDayPicker extends StatefulWidget {
  final List<String> days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
  final Function(List<String>) onSelectionChanged;

  SLCDayPicker({
    Key? key,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _SLCDayPickerState createState() => _SLCDayPickerState();
}

class _SLCDayPickerState extends State<SLCDayPicker> {
  List<String> selectedDays = [];

  void toggleSelection(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day); // Unselect
      } else {
        selectedDays.add(day); // Select
      }
      widget.onSelectionChanged(selectedDays); // Notify parent
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: widget.days.map((day) {
          return SLCDayPickerItem(
            dayLabel: day,
            isSelected: selectedDays.contains(day),
            onTap: () => toggleSelection(day),
          );
        }).toList(),
      ),
    );
  }
}
