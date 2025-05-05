import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/widgets/slceventcard.dart';
import 'package:slc/common/widgets/slcquickactioncard.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/models/Student.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/models/event.dart'; // Add this import
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/repositories/event_repository.dart'; // Add this import
import 'package:intl/intl.dart';
import 'package:slc/features/course%20management/screens/courses.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import at the top
import 'package:slc/features/focus%20sessions/services/focus_session_manager.dart';
import 'package:slc/features/focus%20sessions/widgets/active_session_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import for translations
import 'package:slc/repositories/student_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Firestore

class HomeScreen extends StatefulWidget {
  final Student student;
  const HomeScreen({Key? key, required this.student}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String greeting = "";
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );
  final EventRepository _eventRepository = EventRepository(
    firestoreUtils: FirestoreUtils(),
  );
  final FocusSessionManager _sessionManager = FocusSessionManager();

  // Add focus node to detect when screen is active
  final FocusNode _focusNode = FocusNode();

  // Add these variables
  bool _hasActiveSession = false;
  Course? _activeSessionCourse;
  CourseEnrollment? _activeSessionEnrollment;

  // Add a flag to track if we've checked for sessions after navigation
  bool _checkedActiveSessionAfterNavigation = false;

  @override
  void initState() {
    super.initState();
    // Remove _updateGreeting() from here

    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Listen for session changes
    _sessionManager.addListener(_onSessionChanged);

    // Schedule a check AFTER the first build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkForActiveSession();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateGreeting(); // Move the call here
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _checkForActiveSession();
    }
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset flag when widget updates (like hot reload)
    _checkedActiveSessionAfterNavigation = false;
  }

  // Add this method to handle app lifecycle changes (app resuming from background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // First recalculate the elapsed time to ensure timer accuracy
      if (_sessionManager.isSessionActive && _sessionManager.isPlaying) {
        _sessionManager.recalculateElapsedTimeOnResume();
      }

      // Then check for and restore any active session
      if (mounted) _checkForActiveSession();
    }
  }

  // Replace the _onSessionChanged method
  void _onSessionChanged() {
    if (!mounted) return;

    // Consider sessions active whether playing or paused
    final isActiveNow = _sessionManager.isSessionActive;
    if (isActiveNow != _hasActiveSession) {
      setState(() {
        _hasActiveSession = isActiveNow;
        if (_hasActiveSession) {
          _activeSessionCourse = _sessionManager.course;
          _activeSessionEnrollment = _sessionManager.enrollment;
        } else {
          _activeSessionCourse = null;
          _activeSessionEnrollment = null;
        }
      });
    }
  }

  // Replace the checkForActiveSession method
  void checkForActiveSession() async {
    // Make sure we're mounted before continuing
    if (!mounted) return;

    try {
      // Check if there's an active session (playing OR paused)
      if (_sessionManager.isSessionActive) {
        setState(() {
          _hasActiveSession = true;
          _activeSessionCourse = _sessionManager.course;
          _activeSessionEnrollment = _sessionManager.enrollment;
        });
        return;
      }

      // Try to restore session
      final hasActiveSession = await _sessionManager.restoreSessionIfActive();

      if (mounted) {
        setState(() {
          _hasActiveSession = hasActiveSession;
          if (_hasActiveSession) {
            _activeSessionCourse = _sessionManager.course;
            _activeSessionEnrollment = _sessionManager.enrollment;
          } else {
            _activeSessionCourse = null;
            _activeSessionEnrollment = null;
          }
        });
      }
    } catch (e) {
      print('Error checking for active session: $e');
    }
  }

  // Update your existing _checkForActiveSession to use the public method
  Future<void> _checkForActiveSession() async {
    checkForActiveSession();
  }

  void _updateGreeting() {
    final l10n = AppLocalizations.of(context);
    final int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      greeting = l10n?.goodMorning ?? "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = l10n?.goodAfternoon ?? "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = l10n?.goodEvening ?? "Good Evening";
    } else {
      greeting = l10n?.hello ?? "Hello";
    }
  }

  // Add method to check if event is today
  bool _isEventToday(Event event) {
    final now = DateTime.now();
    return event.dateTime.year == now.year &&
        event.dateTime.month == now.month &&
        event.dateTime.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      // Rest of your build method remains the same
      child: Container(
        padding: SpacingStyles(context).defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - unchanged
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('students')
                            .doc(widget.student.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            // Get latest student name from Firestore
                            final studentData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final updatedName =
                                studentData['name'] ?? widget.student.name;

                            return Text(
                              updatedName,
                              style: Theme.of(context).textTheme.headlineMedium,
                            );
                          }

                          // Fallback to original name if stream not ready
                          return Text(
                            widget.student.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          );
                        },
                      ),
                    ],
                  ),
                  // Replace the PullDownButton with just the StreamBuilder for the avatar
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .doc(widget.student.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String? updatedPhotoUrl;
                      if (snapshot.hasData && snapshot.data != null) {
                        final studentData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        updatedPhotoUrl = studentData['photoUrl'];
                      }

                      return SLCAvatar(
                        imageUrl: updatedPhotoUrl ?? widget.student.photoUrl,
                        size: 55,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: StreamBuilder<List<CourseWithProgress>>(
                stream:
                    _courseRepository.streamStudentCourses(widget.student.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SLCLoadingIndicator(
                        text: l10n?.loadingYourData ??
                            "Loading your schedule...");
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n?.failedToLoadCourses ??
                                "Failed to load your courses",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: Text(l10n?.retry ?? "Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  final allCourses = snapshot.data ?? [];
                  final todayCourses = _getTodaysCourses(allCourses);

                  // Get course IDs for event fetching
                  final courseIds = allCourses.map((c) => c.course.id).toList();

                  // Add nested StreamBuilder for events
                  return StreamBuilder<List<Event>>(
                    stream: _eventRepository.streamAllCoursesEvents(courseIds),
                    builder: (context, eventsSnapshot) {
                      // Handle events loading state
                      if (eventsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SLCLoadingIndicator(
                            text: l10n?.loadingYourData ?? "Loading events...");
                      }

                      // Get today's events
                      final allEvents = eventsSnapshot.data ?? [];
                      final todayEvents =
                          allEvents.where(_isEventToday).toList();

                      // Now we have both courses and events, proceed with UI
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // *** ADD ACTIVE SESSION CARD HERE ***
                            if (_hasActiveSession &&
                                _activeSessionCourse != null &&
                                _activeSessionEnrollment != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.025),
                                  Text(
                                    l10n?.focusSession ?? "Ongoing Session",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  SizedBox(height: 16),
                                  ActiveSessionCard(
                                    course: _activeSessionCourse!,
                                    enrollment: _activeSessionEnrollment!,
                                  ),
                                ],
                              ),

                            // Events section - keep existing
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.025),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n?.events ?? "Events",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // No events or classes today
                                if (todayCourses.isEmpty && todayEvents.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.event_available,
                                            color: Colors.grey),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            l10n?.noEventsToday ??
                                                "No events scheduled",
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Today's classes - keep this unchanged
                                ...todayCourses.map((cwp) {
                                  final course = cwp.course;
                                  final schedule = course.schedule;
                                  if (schedule == null)
                                    return const SizedBox.shrink();

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: SLCEventCard(
                                      color: course.color,
                                      title: course.code,
                                      location: schedule.location,
                                      startTime: schedule.startTime,
                                      endTime: schedule.endTime,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CourseScreen(
                                              courseId: course.id,
                                              enrollment: cwp.enrollment,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),

                                // Today's events - add this section
                                ...todayEvents.map((event) {
                                  // Find course for this event
                                  final matchingCourses = allCourses
                                      .where((cwp) =>
                                          cwp.course.id == event.courseId)
                                      .toList();

                                  // Skip if we can't find the course
                                  if (matchingCourses.isEmpty)
                                    return const SizedBox.shrink();

                                  final eventCourse = matchingCourses.first;

                                  final course = eventCourse.course;

                                  // Convert DateTime to TimeOfDay for the event card
                                  final eventTime = TimeOfDay(
                                    hour: event.dateTime.hour,
                                    minute: event.dateTime.minute,
                                  );

                                  // End time may be null

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: SLCEventCard(
                                      color: course.color,
                                      title: event.title,
                                      location: event.location,
                                      startTime: eventTime,

                                      pinnedText: course
                                          .code, // Show the course code as pinned text
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),

                            // Quick Actions section - unchanged
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.025),
                                Text(
                                  l10n?.quickActions ?? "Quick Actions",
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 20),

                                // No materials - unchanged
                                if (allCourses.isEmpty ||
                                    !allCourses.any(
                                        (c) => c.course.materials.isNotEmpty))
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.book,
                                            color: Colors.grey),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            l10n?.noMaterialsAvailable ??
                                                "No quick actions available",
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Show recent materials as quick actions - unchanged
                                ...allCourses
                                    .expand((cwp) {
                                      final course = cwp.course;
                                      final enrollment = cwp.enrollment;

                                      // Get incomplete materials
                                      final incompleteMaterials = course
                                          .materials
                                          .where((m) => !enrollment
                                              .completedMaterialIds
                                              .contains(m.id))
                                          .take(2); // Just take 2 recent ones

                                      return incompleteMaterials
                                          .map((material) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: SLCQuickActionCard(
                                                  title: course.code,
                                                  chapter: material.name,
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CourseScreen(
                                                          courseId: course.id,
                                                          enrollment:
                                                              enrollment,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ));
                                    })
                                    .take(3)
                                    .toList(), // Limit to 3 total materials
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep your existing methods
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'logout':
        _logoutUser();
        break;
    }
  }

  void _logoutUser() async {
    // Actually sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Then navigate to login screen
    Navigator.pushReplacementNamed(context, '/loginscreen');
  }

  // Check if course has a session today
  bool _isClassToday(CourseSchedule? schedule) {
    if (schedule == null || schedule.days.isEmpty) return false;

    // FOR TESTING: Show all courses as today's courses
    return true;

    // PRODUCTION CODE:
    // final now = DateTime.now();
    // final dayName = DateFormat('EEE').format(now).toUpperCase();
    // return schedule.days.contains(dayName);
  }

  // Get today's courses
  List<CourseWithProgress> _getTodaysCourses(
      List<CourseWithProgress> allCourses) {
    return allCourses
        .where((cwp) => _isClassToday(cwp.course.schedule))
        .toList();
  }
}
