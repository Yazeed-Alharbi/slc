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
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:intl/intl.dart';
import 'package:slc/features/course%20management/screens/courses.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';

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

  void _logoutUser() {
    Navigator.pushReplacementNamed(context, '/loginscreen');
  }

  // Convert CourseColor to EventCardColor
  EventCardColor _getCardColor(CourseColor color) {
    switch (color) {
      case CourseColor.red:
        return EventCardColor.red;
      case CourseColor.green:
        return EventCardColor.green;
      case CourseColor.blue:
        return EventCardColor.blue;
      case CourseColor.yellow:
        return EventCardColor.yellow;
      case CourseColor.purple:
        return EventCardColor.purple;
      case CourseColor.orange:
        return EventCardColor.orange;
      case CourseColor.black:
        return EventCardColor.black;
    }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: SpacingStyles(context).defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  print(
                      "Found ${allCourses.length} courses: ${allCourses.map((c) => c.course.name).join(', ')}");

                  final todayCourses = _getTodaysCourses(allCourses);
                  print("Today's courses: ${todayCourses.length}");

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Events", // Changed from "Today's Classes"
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
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

                            // No classes today
                            if (todayCourses.isEmpty)
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
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Today's classes
                            ...todayCourses.map((cwp) {
                              final course = cwp.course;
                              final schedule = course.schedule;
                              if (schedule == null)
                                return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: SLCEventCard(
                                  color: _getCardColor(course.color),
                                  title: course.code,
                                  location: schedule.location,
                                  startTime: schedule.startTime,
                                  endTime: schedule.endTime,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseScreen(
                                          course: course,
                                          enrollment: cwp.enrollment,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.025),
                            Text(
                              "Quick Actions", // Changed from "Recent Materials"
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),

                            // No materials
                            if (allCourses.isEmpty ||
                                !allCourses
                                    .any((c) => c.course.materials.isNotEmpty))
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.book, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "No quick actions available",
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Show recent materials as quick actions
                            ...allCourses
                                .expand((cwp) {
                                  final course = cwp.course;
                                  final enrollment = cwp.enrollment;

                                  // Get incomplete materials
                                  final incompleteMaterials = course.materials
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
                                                      course: course,
                                                      enrollment: enrollment,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
