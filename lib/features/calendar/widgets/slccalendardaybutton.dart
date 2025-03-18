import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';

class SLCCalendarDayButton extends StatelessWidget {
  final String dayNumber;
  final String dayOfWeek;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? dayNumberStyle;
  final TextStyle? dayOfWeekStyle;

  const SLCCalendarDayButton({
    Key? key,
    required this.dayNumber,
    required this.dayOfWeek,
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.borderColor,
    this.dayNumberStyle,
    this.dayOfWeekStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? SLCColors.primaryColor
              : MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: SLCColors.coolGray,
            width: 0.25,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber,
              style: dayNumberStyle ??
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      color: isSelected ? Colors.white : SLCColors.coolGray),
            ),
            Text(
              dayOfWeek,
              style: dayOfWeekStyle ??
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                      color: isSelected ? Colors.white : SLCColors.coolGray),
            ),
          ],
        ),
      ),
    );
  }
}
