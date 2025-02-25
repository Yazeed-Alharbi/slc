import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/features/course%20management/screens/filestab.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';

class CourseScreen extends StatefulWidget {
  final Course course;
  final CourseEnrollment enrollment;

  const CourseScreen({
    Key? key,
    required this.course,
    required this.enrollment,
  }) : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late CourseColor selectedColor;
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );

  @override
  void initState() {
    selectedColor = widget.course.color;
    super.initState();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to start focus session: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.sizeOf(context).height;
    double screenwidth = MediaQuery.sizeOf(context).width;
    Orientation screenOrientation = MediaQuery.orientationOf(context);

    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              color: SLCColors.getCourseColor(selectedColor),
              height: screenOrientation == Orientation.portrait
                  ? screenheight * 0.35
                  : screenheight * 0.55,
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
                              IconButton(
                                onPressed: () {}, // Add options menu
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 30,
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
                                widget.course.code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.w800,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                widget.course.name,
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
                            width: screenwidth * 0.2,
                            text: "Start Focus Session",
                            backgroundColor: Colors.white,
                            foregroundColor:
                                SLCColors.getCourseColor(selectedColor),
                            icon: Icon(
                              Icons.play_circle,
                              color: SLCColors.getCourseColor(selectedColor),
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
                    "Progress: ${_calculateProgress()}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: SLCColors.getCourseColor(selectedColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _calculateProgress() / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        SLCColors.getCourseColor(selectedColor)),
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
                      children: [
                        FilesTab(
                          course: widget.course,
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
      ),
    );
  }

  double _calculateProgress() {
    if (widget.course.materials.isEmpty) return 0;

    int completedCount = widget.enrollment.completedMaterialIds.length;
    int totalCount = widget.course.materials.length;

    return (completedCount / totalCount * 100).clamp(0, 100);
  }
}
