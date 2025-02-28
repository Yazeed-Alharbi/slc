import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
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
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/Student.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';

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
  bool _isLoading = true;
  String? _errorMessage;
  // Add these two variables
  Key _streamBuilderKey = UniqueKey();
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    // Register observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset the key when dependencies change (which happens on route changes)
    if (_needsRefresh) {
      setState(() {
        _streamBuilderKey = UniqueKey();
        _needsRefresh = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background, refresh the stream
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _streamBuilderKey = UniqueKey();
      });
    }
  }

  void _navigateToAddCourse() async {
    final result = await Navigator.pushNamed(context, "/addcourse");

    // Mark for refresh
    _needsRefresh = true;

    if (result == "success") {
      if (mounted) {
        SLCFlushbar.show(
          context: context,
          message: "Course added successfully!",
          type: FlushbarType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.sizeOf(context).width;
    return PopScope(
      // Force refresh when returning via system back button
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
                    "Courses",
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
                  // Add the key here to force rebuild
                  key: _streamBuilderKey,
                  stream: _courseRepository
                      .streamStudentCourses(widget.student.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              SLCLoadingIndicator(text: "Loading courses..."));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Error loading courses",
                              style: TextStyle(fontSize: 16),
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
                              text: "Retry",
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
                            const Text(
                              "You haven't enrolled in any courses yet",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SLCButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/addcourse");
                              },
                              text: "Add Course",
                              backgroundColor: SLCColors.primaryColor,
                              foregroundColor: Colors.white,
                            )
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: coursesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final courseWithProgress = coursesList[index];
                        final course = courseWithProgress.course;

                        List<String> notifications = [];

                        if (course.materials.isNotEmpty) {
                          final incompleteMaterials = course.materials
                              .where((material) => !courseWithProgress
                                  .enrollment.completedMaterialIds
                                  .contains(material.id))
                              .take(3); // Limit to 3 notifications

                          notifications.addAll(incompleteMaterials
                              .map((material) => material.name));
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modify the navigation to CourseScreen to force refresh on return
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

    // Force refresh when returning from CourseScreen
    setState(() {
      _streamBuilderKey = UniqueKey();
    });
  }
}
