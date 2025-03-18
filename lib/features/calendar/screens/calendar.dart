import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slciconbutton.dart';
import 'package:slc/features/calendar/widgets/slccalendardaybutton.dart';
import 'package:slc/features/calendar/widgets/slccalendareventcard.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScrollController _scrollController = ScrollController();
  DateTime _currentMonth = DateTime.now();
  List<DateTime> _visibleDates = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Generate dates for current month
    _generateDatesForMonth(_currentMonth);

    // Set initial selection to today or first day of month
    _setInitialSelection();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Generate dates for a specific month
  void _generateDatesForMonth(DateTime month) {
    // Get the first day of the month
    final firstDay = DateTime(month.year, month.month, 1);

    // Get the last day of the month
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Generate list of dates for the month
    _visibleDates = List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  // Set initial selection to today if in current month, otherwise null
  void _setInitialSelection() {
    final today = DateTime.now();

    // Only select today if we're in the current month
    if (today.year == _currentMonth.year &&
        today.month == _currentMonth.month) {
      _selectedIndex = today.day - 1; // 0-based index

      // Scroll to today after build with a better centering calculation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          // Get available width
          final screenWidth = MediaQuery.of(context).size.width;
          // Calculate button width (96.0 is button + padding)
          const buttonWidth = 94.0;
          // Calculate position to center the button
          final position = (_selectedIndex! * buttonWidth) -
              (screenWidth / 2) +
              (buttonWidth / 2);

          // Ensure position is not negative
          final scrollPosition = position < 0 ? 0.0 : position;

          _scrollController.animateTo(
            scrollPosition,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      _selectedIndex = null; // Don't select any day
    }
  }

  // Navigate to previous month
  void _goToPreviousMonth() {
    setState(() {
      // Decrease month by 1
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _generateDatesForMonth(_currentMonth);

      // Use _setInitialSelection instead of hardcoding to index 0
      _setInitialSelection();
    });
  }

  // Navigate to next month
  void _goToNextMonth() {
    setState(() {
      // Increase month by 1
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _generateDatesForMonth(_currentMonth);

      // Use _setInitialSelection instead of hardcoding to index 0
      _setInitialSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: SpacingStyles(context).defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 7),
            Text(
              "Calendar",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 25),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${DateFormat('MMMM d, yyyy').format(DateTime.now())}",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 24),
                ),
                Text(
                  "2 tasks today",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SLCIconButton(
                    border: Border.all(
                      color: SLCColors.coolGray,
                      width: 0.25,
                    ),
                    onPressed: _goToPreviousMonth,
                    backgroundColor:
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.white
                            : Colors.black,
                    iconColor: SLCColors.coolGray,
                    size: 25,
                    icon: Icons.arrow_back),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 20),
                ),
                SLCIconButton(
                    border: Border.all(
                      color: SLCColors.coolGray,
                      width: 0.25,
                    ),
                    onPressed: _goToNextMonth,
                    backgroundColor:
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.white
                            : Colors.black,
                    iconColor: SLCColors.coolGray,
                    size: 25,
                    icon: Icons.arrow_forward),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 90, // Set appropriate height
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _visibleDates.length,
                itemBuilder: (context, index) {
                  final date = _visibleDates[index];
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SLCCalendarDayButton(
                      dayNumber: date.day.toString(),
                      dayOfWeek: DateFormat('E').format(date).substring(0, 3),
                      isSelected: (_selectedIndex == index) ||
                          (_selectedIndex == null && isToday),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            // Add a small gap
            SizedBox(height: 16),

            // Add the schedule view - make it scrollable and take remaining space
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 13, // 8 AM to 8 PM (13 hours)
                  itemBuilder: (context, index) {
                    final hour = index + 8; // Start from 8 AM
                    final time = hour < 12
                        ? '$hour AM'
                        : hour == 12
                            ? '12 PM'
                            : '${hour - 12} PM';

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height:
                          100, // Increased from 70 to 100 for more vertical space
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time indicator
                          Container(
                            width: 60,
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              time,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // Vertical line - make it fill the entire height
                          Container(
                            width: 1,
                            // Remove the fixed height
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            // Use decoration instead of color to allow full height
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),

                          // Event area remains the same
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              alignment: Alignment.centerLeft,
                              child: _getEventsForTimeSlot(hour),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getEventsForTimeSlot(int hour) {
    // This would be replaced with actual logic to get events for this hour

    // Just for demonstration, let's add sample events
    if (hour == 10) {
      return SLCCalendarEventCard(
        title: "Team Meeting",
        location: "Conference Room",
        startTime: DateTime.now().copyWith(hour: 10, minute: 0),
        endTime: DateTime.now().copyWith(hour: 11, minute: 30),
        color: SLCColors.getCourseColorFromString("tealGreen"),
        onTap: () {
          // Handle event tap
          print("Team meeting tapped");
        },
      );
    } else if (hour == 14) {
      return SLCCalendarEventCard(
        title: "Project Review",
        location: "Room 302",
        startTime: DateTime.now().copyWith(hour: 14, minute: 0),
        endTime: DateTime.now().copyWith(hour: 15, minute: 0),
        color: SLCColors.getCourseColorFromString("navyBlue"),
        onTap: () {
          // Handle event tap
          print("Project review tapped");
        },
      );
    }

    return Container(); // Empty container for time slots with no events
  }
}
