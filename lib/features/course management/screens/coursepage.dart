import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/course%20management/screens/filestab.dart';
import 'package:slc/features/course%20management/widgets/courseform.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';

class CourseScreen extends StatefulWidget {
  final String courseId;
  final CourseEnrollment enrollment;

  const CourseScreen({
    Key? key,
    required this.courseId,
    required this.enrollment,
  }) : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> with SingleTickerProviderStateMixin {
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Course?>(
      stream: _courseRepository.streamCourse(widget.courseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: SLCLoadingIndicator(text: "Loading course...")),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Error loading course"),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ),
          );
        }

        final course = snapshot.data!;

        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                color: SLCColors.getCourseColor(course.color),
                height: MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.35
                    : MediaQuery.of(context).size.height * 0.55,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      right: -150,
                      top: -150,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(65, 227, 227, 227),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SpacingStyles(context).defaultPadding.right,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Navigation Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                PullDownButton(
                                  itemBuilder: (context) => [
                                    PullDownMenuItem(
                                      onTap: () => _handleMenuSelection('edit', course),
                                      title: "Edit",
                                      icon: Icons.edit,
                                    ),
                                    PullDownMenuItem(
                                      onTap: () => _handleMenuSelection('delete', course),
                                      title: "Delete",
                                      isDestructive: true,
                                      icon: Icons.delete,
                                    ),
                                  ],
                                  buttonBuilder: (context, showMenu) =>
                                      GestureDetector(
                                    onTap: showMenu,
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  course.code,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.w800,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  course.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SLCButton(
                              onPressed: _startFocusSession,
                              width: MediaQuery.of(context).size.width * 0.2,
                              text: "Start Focus Session",
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  SLCColors.getCourseColor(course.color),
                              icon: Icon(
                                Icons.play_circle,
                                color: SLCColors.getCourseColor(course.color),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progress: ${_calculateProgress(course)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: SLCColors.getCourseColor(course.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _calculateProgress(course) / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          SLCColors.getCourseColor(course.color)),
                    ),
                  ],
                ),
              ),

              // Tabs Section
              Expanded(
                child: Column(
                  children: [
                    // TabBar
                    TabBar(
                      controller: _tabController,
                      labelColor: SLCColors.primaryColor,
                      indicatorColor: SLCColors.primaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: SLCColors.coolGray,
                      dividerColor: const Color.fromARGB(147, 127, 127, 127),
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      tabs: const [
                        Tab(text: "Files"),
                        Tab(text: "Notes"),
                        Tab(text: "Events"),
                      ],
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          FilesTab(
                            course: course,
                            enrollment: widget.enrollment,
                          ),
                          const Center(child: Text("Notes Content")),
                          const Center(child: Text("Events Content")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startFocusSession() async {
    // Create a new focus session and link it to this course enrollment
    final focusSessionId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await _courseRepository.addFocusSession(
        enrollmentId: widget.enrollment.id,
        focusSessionId: focusSessionId,
      );

      // Navigate to focus session screen or show timer
      // ...
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to start focus session: $e")),
        );
      }
    }
  }

  void _handleMenuSelection(String value, Course course) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CourseFormScreen(
              course: course,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 200),
            reverseTransitionDuration: const Duration(milliseconds: 200),
          ),
        );
        HapticFeedback.lightImpact();
        break;
      case 'delete':
        // Implement delete functionality
        _showDeleteConfirmation(course);
        break;
    }
  }
  
  void _showDeleteConfirmation(Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: const Text('Are you sure you want to delete this course? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCourse(course.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  void _deleteCourse(String courseId) async {
    try {
      // Add this method to your repository
      // await _courseRepository.deleteCourse(courseId);
      Navigator.of(context).pop(); // Return to courses list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete course: $e")),
        );
      }
    }
  }

  double _calculateProgress(Course course) {
    if (course.materials.isEmpty) return 0;

    int completedCount = widget.enrollment.completedMaterialIds.length;
    int totalCount = course.materials.length;

    return (completedCount / totalCount * 100).clamp(0, 100);
  }
}
