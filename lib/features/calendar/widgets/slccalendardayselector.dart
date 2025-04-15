import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/features/calendar/widgets/slccalendardaybutton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    // Function to get localized day name
    String getLocalizedDayName(int weekday) {
      switch (weekday) {
        case DateTime.monday:
          return l10n?.mon ?? "Mon";
        case DateTime.tuesday:
          return l10n?.tue ?? "Tue";
        case DateTime.wednesday:
          return l10n?.wed ?? "Wed";
        case DateTime.thursday:
          return l10n?.thu ?? "Thu";
        case DateTime.friday:
          return l10n?.fri ?? "Fri";
        case DateTime.saturday:
          return l10n?.sat ?? "Sat";
        case DateTime.sunday:
          return l10n?.sun ?? "Sun";
        default:
          return "";
      }
    }

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

          // Get the localized day name
          final dayOfWeek = getLocalizedDayName(date.weekday);

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SLCCalendarDayButton(
              dayNumber: date.day.toString(),
              dayOfWeek: dayOfWeek,
              isSelected: (selectedIndex == index),
              onTap: () => onDaySelected(index),
              isToday: isToday,
            ),
          );
        },
      ),
    );
  }
}
