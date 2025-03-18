import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/features/calendar/widgets/slccalendardaybutton.dart';

class SLCCalendarDaySelector extends StatelessWidget {
  final List<DateTime> dates;
  final int? selectedIndex;
  final Function(int) onDaySelected;
  final ScrollController scrollController;

  const SLCCalendarDaySelector({
    Key? key,
    required this.dates,
    required this.selectedIndex,
    required this.onDaySelected,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SLCCalendarDayButton(
              dayNumber: date.day.toString(),
              dayOfWeek: DateFormat('E').format(date).substring(0, 3),
              isSelected: (selectedIndex == index),
              onTap: () => onDaySelected(index),
            ),
          );
        },
      ),
    );
  }
}
