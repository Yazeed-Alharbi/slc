import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';
import 'package:slc/features/course%20management/widgets/slccoursecard.dart';
import 'package:slc/common/widgets/slciconbutton.dart';
import 'package:slc/common/widgets/slcquickactioncard.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/repositories/event_repository.dart'; // Add this import
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/Student.dart';
import 'package:slc/models/event.dart'; // Add this import
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class CoursesScreen extends StatefulWidget {
  final Student student;

  const CoursesScreen({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with WidgetsBindingObserver {
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );
  // Add event repository
  final EventRepository _eventRepository = EventRepository(
    firestoreUtils: FirestoreUtils(),
  );

  bool _isLoading = true;
  String? _errorMessage;
  Key _streamBuilderKey = UniqueKey();
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_needsRefresh) {
      setState(() {
        _streamBuilderKey = UniqueKey();
        _needsRefresh = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _streamBuilderKey = UniqueKey();
      });
    }
  }

  void _navigateToAddCourse() async {
    final result = await Navigator.pushNamed(context, "/addcourse");
    _needsRefresh = true;
    if (result == "success") {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        SLCFlushbar.show(
          context: context,
          message: l10n?.courseAddedSuccess ?? "Course added successfully!",
          type: FlushbarType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    double _screenWidth = MediaQuery.sizeOf(context).width;
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() {
          _streamBuilderKey = UniqueKey();
        });
      },
      child: SafeArea(
        child: Container(
          padding: SpacingStyles(context).defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.courses ?? "Courses",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 25),
                    textAlign: TextAlign.start,
                  ),
                  SLCIconButton(
                      onPressed: () {
                        _navigateToAddCourse();
                      },
                      backgroundColor: SLCColors.primaryColor,
                      iconColor: Colors.white,
                      icon: Icons.add)
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<CourseWithProgress>>(
                  key: _streamBuilderKey,
                  stream: _courseRepository
                      .streamStudentCourses(widget.student.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: SLCLoadingIndicator(
                              text: l10n?.loadingCourses ??
                                  "Loading courses..."));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n?.errorLoadingCourses ??
                                  "Error loading courses",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            SLCButton(
                              onPressed: () => setState(() {}),
                              text: l10n?.retry ?? "Retry",
                              backgroundColor: SLCColors.primaryColor,
                              foregroundColor: Colors.white,
                            )
                          ],
                        ),
                      );
                    }

                    final coursesList = snapshot.data ?? [];

                    if (coursesList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n?.noCoursesEnrolled ??
                                  "You haven't enrolled in any courses yet",
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SLCButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/addcourse");
                              },
                              text: l10n?.addCourse ?? "Add Course",
                              backgroundColor: SLCColors.primaryColor,
                              foregroundColor: Colors.white,
                            )
                          ],
                        ),
                      );
                    }

                    // Get all course IDs for events query
                    final courseIds =
                        coursesList.map((cwp) => cwp.course.id).toList();

                    // Add nested StreamBuilder for events
                    return StreamBuilder<List<Event>>(
                      stream:
                          _eventRepository.streamAllCoursesEvents(courseIds),
                      builder: (context, eventsSnapshot) {
                        if (eventsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SLCLoadingIndicator(
                                text:
                                    l10n?.loadingEvents ?? "Loading events..."),
                          );
                        }

                        final allEvents = eventsSnapshot.data ?? [];

                        return ListView.separated(
                          itemCount: coursesList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final courseWithProgress = coursesList[index];
                            final course = courseWithProgress.course;

                            // Filter events for this specific course
                            final courseEvents = allEvents
                                .where((event) => event.courseId == course.id)
                                .toList();

                            // Sort events by date (most recent first)
                            courseEvents.sort(
                                (a, b) => a.dateTime.compareTo(b.dateTime));

                            // Create notifications from upcoming events (limit to 3)
                            List<String> notifications = [];

                            if (courseEvents.isNotEmpty) {
                              // Get upcoming events (today or later)
                              final now = DateTime.now();
                              final upcomingEvents = courseEvents
                                  .where((event) => event.dateTime.isAfter(
                                      DateTime(now.year, now.month, now.day)))
                                  .take(3)
                                  .toList();

                              if (upcomingEvents.isNotEmpty) {
                                // Format events as notifications
                                notifications = upcomingEvents.map((event) {
                                  return event.title;
                                }).toList();
                              }
                            }

                            return SLCCourseCard(
                              color: course.color,
                              title: course.code,
                              name: course.name,
                              notifications: notifications,
                              onTap: () {
                                _navigateToCourseScreen(
                                    course, courseWithProgress.enrollment);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Unchanged navigation method
  void _navigateToCourseScreen(
      Course course, CourseEnrollment enrollment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseScreen(
          courseId: course.id,
          enrollment: enrollment,
        ),
      ),
    );

    setState(() {
      _streamBuilderKey = UniqueKey();
    });
  }
}
