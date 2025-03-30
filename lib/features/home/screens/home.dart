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
import 'package:slc/models/event.dart'; // Add this import
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/repositories/event_repository.dart'; // Add this import
import 'package:intl/intl.dart';
import 'package:slc/features/course%20management/screens/courses.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import at the top

class HomeScreen extends StatefulWidget {
  final Student student;
  const HomeScreen({Key? key, required this.student}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greeting = "";
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );
  // Add event repository
  final EventRepository _eventRepository = EventRepository(
    firestoreUtils: FirestoreUtils(),
  );

  @override
  void initState() {
    super.initState();
    _updateGreeting();
  }

  void _updateGreeting() {
    final int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good Evening";
    } else {
      greeting = "Hello";
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
    return SafeArea(
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
                      Text(
                        widget.student.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  PullDownButton(
                    itemBuilder: (context) => [
                      PullDownMenuItem(
                        onTap: () => {},
                        title: "Settings",
                        icon: Icons.settings,
                      ),
                      PullDownMenuItem(
                        onTap: () => _handleMenuSelection('logout'),
                        title: "Logout",
                        isDestructive: true,
                        icon: Icons.logout,
                      ),
                    ],
                    buttonBuilder: (context, showMenu) => GestureDetector(
                      onTap: showMenu,
                      child: SLCAvatar(
                        imageUrl: widget.student.photoUrl,
                        size: 55,
                      ),
                    ),
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
                    return const Center(
                      child:
                          SLCLoadingIndicator(text: "Loading your schedule..."),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Failed to load your courses",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: const Text("Retry"),
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
                        return const Center(
                          child: SLCLoadingIndicator(text: "Loading events..."),
                        );
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
                                      "Events",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CoursesScreen(
                                              student: widget.student,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("See All"),
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
                                  "Quick Actions",
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
