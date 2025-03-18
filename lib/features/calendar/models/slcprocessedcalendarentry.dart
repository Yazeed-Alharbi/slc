import 'package:slc/features/calendar/models/slccalendarentry.dart';

class SLCProcessedCalendarEntry {
  final SLCCalendarEntry entry;
  final double widthFactor;
  final double leftPosition;

  SLCProcessedCalendarEntry({
    required this.entry,
    required this.widthFactor,
    required this.leftPosition,
  });
}
