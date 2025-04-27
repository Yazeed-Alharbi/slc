import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/features/calendar/models/slccalendarentry.dart';
import 'package:slc/features/calendar/widgets/slccalendarheader.dart';
import 'package:slc/features/calendar/widgets/slccalendardayselector.dart';
import 'package:slc/features/calendar/widgets/slccalendartimegrid.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/event.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/repositories/event_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScrollController _scrollController = ScrollController();
  DateTime _currentMonth = DateTime.now();
  List<DateTime> _visibleDates = [];
  DateTime _selectedDate = DateTime.now();
  int? _selectedIndex;
  List<SLCCalendarEntry> _calendarEntries = [];
  bool _isLoading = true;

  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );

  final EventRepository _eventRepository = EventRepository(
    firestoreUtils: FirestoreUtils(),
  );

  @override
  void initState() {
    super.initState();
    // Generate dates for current month
    _generateDatesForMonth(_currentMonth);
    _setInitialSelection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCalendarData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCalendarData() async {
    if (!mounted) return; // Early return if widget is already disposed

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'current_user_id';

      // Get student courses
      final coursesWithProgress =
          await _courseRepository.streamStudentCourses(userId).first;
      final courseIds =
          coursesWithProgress.map((cwp) => cwp.course.id).toList();

      List<SLCCalendarEntry> entries = [];

      // Load course entries
      for (var cwp in coursesWithProgress) {
        final entry = SLCCalendarEntry.fromCourseSchedule(
          course: cwp.course,
          date: _selectedDate,
          onTap: () {/* Navigate to course */},
        );

        if (entry != null) {
          entries.add(entry);
        }
      }

      // Load event entries
      if (courseIds.isNotEmpty) {
        final events =
            await _eventRepository.streamAllCoursesEvents(courseIds).first;

        // ... rest of your loading code ...
      }

      entries.sort((a, b) => a.startTime.compareTo(b.startTime));

      if (!mounted) return; // Check again before setState

      setState(() {
        _calendarEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading calendar data: $e');

      if (!mounted) return; // Check before setState on error path

      setState(() => _isLoading = false);
    }
  }

  void _generateDatesForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    _visibleDates = List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  void _setInitialSelection() {
    final today = DateTime.now();

    if (today.year == _currentMonth.year &&
        today.month == _currentMonth.month) {
      _selectedIndex = today.day - 1;
      _selectedDate = DateTime(today.year, today.month, today.day);

      // Scroll to today
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final screenWidth = MediaQuery.of(context).size.width;
          const buttonWidth = 94.0;
          final position = (_selectedIndex! * buttonWidth) -
              (screenWidth / 2) +
              (buttonWidth / 2);
          final scrollPosition = position < 0 ? 0.0 : position;

          _scrollController.animateTo(
            scrollPosition,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      _selectedIndex = 0; // Select first day of month
      _selectedDate = _visibleDates.first;
    }
  }

  void _onMonthChanged(bool next) {
    setState(() {
      _currentMonth = DateTime(
          _currentMonth.year, _currentMonth.month + (next ? 1 : -1), 1);
      _generateDatesForMonth(_currentMonth);
      _setInitialSelection();
      _loadCalendarData();
    });
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedDate = _visibleDates[index];
      _loadCalendarData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: SpacingStyles(context).defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 7),
              Text(
                l10n?.calendar ?? "Calendar",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 25),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 20),

              // Calendar header with month selector
              SLCCalendarHeader.SLCCalendarHeader(
                currentMonth: _currentMonth,
                onPrevious: () => _onMonthChanged(false),
                onNext: () => _onMonthChanged(true),
              ),

              SizedBox(height: 20),

              // Day selector
              SLCCalendarDaySelector(
                dates: _visibleDates,
                selectedIndex: _selectedIndex,
                onDaySelected: _onDaySelected,
                scrollController: _scrollController,
              ),

              SizedBox(height: 16),

              // Calendar time grid
              SLCCalendarTimeGrid(
                entries: _calendarEntries,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
