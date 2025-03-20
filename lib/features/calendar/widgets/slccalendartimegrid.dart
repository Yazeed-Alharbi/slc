import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/calendar/models/slccalendarentry.dart';
import 'package:slc/features/calendar/widgets/slccalendarentryprocessor.dart';
import 'package:slc/features/calendar/widgets/slccalendartimeslots.dart';
import 'package:slc/features/calendar/widgets/slccalendarentrywidget.dart';

class SLCCalendarTimeGrid extends StatelessWidget {
  final List<SLCCalendarEntry> entries;
  final bool isLoading;

  const SLCCalendarTimeGrid({
    Key? key,
    this.entries = const [],
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show loading state that completely replaces the calendar
    if (isLoading) {
      return Container(
        height: 400, // Shorter height while loading
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: SLCLoadingIndicator(),
        ),
      );
    }

    // Process calendar entries to handle overlaps
    final processedEntries = SLCCalendarEntryProcessor.processEntries(entries);

    // Show full calendar when not loading
    return Container(
      height: 2400, // 24 hours × 100px per hour
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Time slots background
          SLCCalendarTimeSlots(),

          // Half-hour lines
          ...List.generate(24, (index) {
            return Positioned(
              top: (index * 100) + 50, // Position at half-hour marks
              left: 85,
              right: 16,
              child: Container(
                height: 1,
                color: Colors.grey.withOpacity(0.1),
              ),
            );
          }),

          // Calendar entries positioned based on their times
          ...processedEntries.map((groupedEntries) =>
              SLCCalendarEntryWidget(entries: groupedEntries)),
        ],
      ),
    );
  }
}
