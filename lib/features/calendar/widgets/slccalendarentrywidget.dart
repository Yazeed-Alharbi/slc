import 'package:flutter/material.dart';
import 'package:slc/features/calendar/models/slcprocessedcalendarentry.dart';
import 'package:slc/features/calendar/widgets/slccalendareventcard.dart';

class SLCCalendarEntryWidget extends StatelessWidget {
  final List<SLCProcessedCalendarEntry> entries;

  const SLCCalendarEntryWidget({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return Container();

    // All entries in this group share the same time slot
    final firstEntry = entries.first.entry;

    // Calculate position based on start time (accurate to the minute)
    final startHour =
        firstEntry.startTime.hour + (firstEntry.startTime.minute / 60);

    // Calculate height - handle events that might cross midnight
    final endHour = firstEntry.endTime.hour + (firstEntry.endTime.minute / 60);

    // For events near midnight (11:45 PM or later), add special handling
    final isLateNightEvent = (startHour >= 23.75);

    // Calculate position from top (pixels)
    final top = startHour * 100; // Each hour is 100px tall

    // Calculate height with enhanced visibility for late night events
    double height;

    if (isLateNightEvent) {
      height = 80.0; // Fixed larger height for very late events
    } else {
      // Normal height calculation for regular events
      height = (endHour - startHour) * 100;

      // Minimum height for regular events
      if (height < 40) {
        height = 40;
      }
    }

    // Make sure we don't go off the bottom of our calendar
    if (top + height > 2380) {
      return Positioned(
        top: 2380 - height,
        left: 85,
        right: 16,
        height: height,
        child: entries.length == 1
            ? _buildSingleCalendarEntry(entries.first)
            : _buildScrollableCalendarEntries(entries),
      );
    }

    // Regular positioning for other events
    return Positioned(
      top: top,
      left: 85,
      right: 16,
      height: height,
      child: entries.length == 1
          ? _buildSingleCalendarEntry(entries.first)
          : _buildScrollableCalendarEntries(entries),
    );
  }

  // Build a single calendar entry
  Widget _buildSingleCalendarEntry(SLCProcessedCalendarEntry processedEntry) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: SLCCalendarEventCard(
        title: processedEntry.entry.title,
        location: processedEntry.entry.location,
        startTime: processedEntry.entry.startTime,
        endTime: processedEntry.entry.endTime,
        color: processedEntry.entry.color,
        onTap: processedEntry.entry.onTap,
      ),
    );
  }

  // Build horizontally scrollable overlapping calendar entries
  Widget _buildScrollableCalendarEntries(
      List<SLCProcessedCalendarEntry> entries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: entries.map((processedEntry) {
          // Calculate width - fixed width for each card with spacing
          final cardWidth = 200.0; // Fixed width for scrollable cards

          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: 8), // Gap between cards
            child: SLCCalendarEventCard(
              title: processedEntry.entry.title,
              location: processedEntry.entry.location,
              startTime: processedEntry.entry.startTime,
              endTime: processedEntry.entry.endTime,
              color: processedEntry.entry.color,
              onTap: processedEntry.entry.onTap,
            ),
          );
        }).toList(),
      ),
    );
  }
}
