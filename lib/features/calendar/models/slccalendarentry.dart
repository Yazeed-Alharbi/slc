import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/event.dart';
import 'package:intl/intl.dart';

class SLCCalendarEntry {
  final String id;
  final String title;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final CourseColor color;
  final bool isClassSession;
  final String? courseId;
  final bool hasDefinedEndTime; // Add this property
  final VoidCallback? onTap;

  SLCCalendarEntry({
    required this.id,
    required this.title,
    this.location,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.isClassSession = false,
    this.courseId,
    this.hasDefinedEndTime = true, // Default to true
    this.onTap,
  });

  // Factory to create from Course schedule
  static SLCCalendarEntry? fromCourseSchedule({
    required Course course,
    required DateTime date,
    VoidCallback? onTap,
  }) {
    final schedule = course.schedule;
    if (schedule == null) return null;

    // Get the day name in different formats for more robust matching
    final fullDayName = DateFormat('EEEE').format(date); // "Monday"
    final shortDayName = DateFormat('EEE').format(date); // "Mon"
    final veryShortDayName = DateFormat('E').format(date); // "M"

    // Try to match day in any format
    bool dayMatches = false;

    // Debug print
    print(
        "DEBUG: Checking if course day matches - Schedule days: ${schedule.days}, Selected day: $fullDayName");

    for (var scheduledDay in schedule.days) {
      // Convert to lowercase for case-insensitive comparison
      final day = scheduledDay.toLowerCase();

      if (day == fullDayName.toLowerCase() ||
          day == shortDayName.toLowerCase() ||
          day == veryShortDayName.toLowerCase() ||
          // Try truncated versions
          fullDayName.toLowerCase().startsWith(day) ||
          // Some may store as: "Monday,Tuesday,Wednesday"
          day.contains(fullDayName.toLowerCase()) ||
          day.contains(shortDayName.toLowerCase())) {
        dayMatches = true;
        print(
            "DEBUG: Day match found! $scheduledDay matches with $fullDayName");
        break;
      }
    }

    if (!dayMatches) {
      print("DEBUG: No day match for course ${course.name} on $fullDayName");
      return null;
    }

    // Convert TimeOfDay to DateTime
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      schedule.startTime.hour,
      schedule.startTime.minute,
    );

    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      schedule.endTime.hour,
      schedule.endTime.minute,
    );

    print(
        "DEBUG: Creating calendar entry for course ${course.name} on $fullDayName");

    return SLCCalendarEntry(
      id: '${course.id}_${date.toIso8601String()}',
      title: '${course.code}',
      location: schedule.location,
      startTime: startDateTime,
      endTime: endDateTime,
      color: course.color,
      isClassSession: true,
      courseId: course.id,
      onTap: onTap,
    );
  }

  // Factory to create from Event
  static SLCCalendarEntry fromEvent({
    required Event event,
    required CourseColor color,
    VoidCallback? onTap,
  }) {
    // Default to 1-hour duration if no end time
    final endTime = DateTime(event.dateTime.year, event.dateTime.month,
        event.dateTime.day, event.dateTime.hour + 1, event.dateTime.minute);

    // For this factory, assume events don't have a defined end time
    // This could be changed if your Event class actually has an endTime field
    const hasDefinedEndTime = false;

    return SLCCalendarEntry(
      id: event.id,
      title: event.title,
      location: event.location,
      startTime: event.dateTime,
      endTime: endTime,
      color: color,
      isClassSession: false,
      courseId: event.courseId,
      hasDefinedEndTime: hasDefinedEndTime,
      onTap: onTap,
    );
  }
}
