import 'package:flutter/material.dart';
import 'package:slc/features/calendar/models/slcprocessedcalendarentry.dart';
import 'package:slc/features/calendar/widgets/slccalendareventcard.dart';

class SLCCalendarEntryWidget extends StatelessWidget {
  final List<SLCProcessedCalendarEntry> entries;
  final double timeColumnWidth;
  final bool isRTL;

  const SLCCalendarEntryWidget({
    Key? key,
    required this.entries,
    required this.timeColumnWidth,
    this.isRTL = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return SizedBox.shrink();

    final entry = entries.first;
    final startHour = entry.entry.startTime.hour;
    final startMinute = entry.entry.startTime.minute;
    
    final endTime = entry.entry.endTime;
    final durationMinutes = endTime.difference(entry.entry.startTime).inMinutes;
    final height = (durationMinutes / 60) * 100; // 100px per hour
    
    // Calculate top position
    final topPosition = (startHour * 100) + ((startMinute / 60) * 100);
    
    // Calculate horizontal positioning based on RTL
    final padding = 16.0;
    
    return Positioned(
      top: topPosition,
      // In RTL mode, position from right edge at timeColumnWidth
      // In LTR mode, position from left edge at timeColumnWidth
      left: isRTL ? padding : timeColumnWidth,
      right: isRTL ? timeColumnWidth : padding,
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
