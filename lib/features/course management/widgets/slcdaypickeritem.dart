import 'package:flutter/material.dart';

class SLCDayPickerItem extends StatelessWidget {
  final String dayLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const SLCDayPickerItem({
    Key? key,
    required this.dayLabel,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 81, 0, 255) // Selected color
              : const Color.fromARGB(93, 81, 0, 255), // Default color
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            dayLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
