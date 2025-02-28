import 'package:flutter/material.dart';
import 'slcdaypickeritem.dart';

class SLCDayPicker extends StatefulWidget {
  final List<String> days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
  final Function(List<String>) onSelectionChanged;
  final List<String> initialSelection; // Add this parameter

  SLCDayPicker({
    Key? key,
    required this.onSelectionChanged,
    this.initialSelection = const [], // Default to empty list
  }) : super(key: key);

  @override
  _SLCDayPickerState createState() => _SLCDayPickerState();
}

class _SLCDayPickerState extends State<SLCDayPicker> {
  late List<String> selectedDays;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided selection
    selectedDays = List<String>.from(widget.initialSelection);
    
    // Notify parent about the initial selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelectionChanged(selectedDays);
    });
  }

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