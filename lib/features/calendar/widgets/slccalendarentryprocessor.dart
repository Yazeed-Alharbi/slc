import 'package:slc/features/calendar/models/slccalendarentry.dart';
import 'package:slc/features/calendar/models/slcprocessedcalendarentry.dart';

class SLCCalendarEntryProcessor {
  static List<List<SLCProcessedCalendarEntry>> processEntries(
      List<SLCCalendarEntry> entries) {
    if (entries.isEmpty) return [];

    // Sort entries by start time
    final sortedEntries = List<SLCCalendarEntry>.from(entries)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Group entries by overlapping time slots
    final List<List<SLCCalendarEntry>> timeSlotGroups = [];

    for (final entry in sortedEntries) {
      bool addedToGroup = false;

      // Try to add to an existing group if it overlaps
      for (final group in timeSlotGroups) {
        if (group.any((groupEntry) => _doEventsOverlap(entry, groupEntry))) {
          group.add(entry);
          addedToGroup = true;
          break;
        }
      }

      // Create new group if it doesn't fit in any existing group
      if (!addedToGroup) {
        timeSlotGroups.add([entry]);
      }
    }

    // Convert groups to processed entries
    return timeSlotGroups.map((group) {
      final groupLength = group.length;
      return group.asMap().entries.map((e) {
        final index = e.key;
        final entry = e.value;
        return SLCProcessedCalendarEntry(
          entry: entry,
          widthFactor: 1.0 / groupLength,
          leftPosition: index / groupLength,
        );
      }).toList();
    }).toList();
  }

  static bool _doEventsOverlap(
      SLCCalendarEntry entry1, SLCCalendarEntry entry2) {
    return entry1.startTime.isBefore(entry2.endTime) &&
        entry2.startTime.isBefore(entry1.endTime);
  }
}
