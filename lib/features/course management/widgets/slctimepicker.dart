import 'package:flutter/material.dart';

class SLCTimePicker extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;
  final TimeOfDay? initialTime;

  const SLCTimePicker({
    Key? key,
    required this.onTimeSelected,
    this.initialTime,
  }) : super(key: key);

  @override
  _SLCTimePickerState createState() => _SLCTimePickerState();
}

class _SLCTimePickerState extends State<SLCTimePicker> {
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    
    // Notify parent about the initial time if provided
    if (selectedTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTimeSelected(selectedTime!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input, 
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false), 
          child: child!,
        );
      },
      onEntryModeChanged: (mode) {
        if (mode != TimePickerEntryMode.dial) {
          Navigator.of(context).pop();
        }
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
      widget.onTimeSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => _selectTime(context),
          style: TextButton.styleFrom(
            overlayColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            selectedTime != null ? selectedTime!.format(context) : "--:--",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}