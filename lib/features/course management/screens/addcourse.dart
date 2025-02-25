import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/features/course%20management/widgets/slccolorpicker.dart';
import 'package:slc/features/course%20management/widgets/slcheadertextfield.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/features/course%20management/widgets/slctimepicker.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/repositories/course_repository.dart';

import '../widgets/slcdaypicker.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  late Color selectedColor;
  String? courseName;
  String? courseTitle;
  List<String> selectedDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? location; // This is optional
  bool _isLoading = false;

  @override
  void initState() {
    selectedColor = SLCColors.navyBlue;
    super.initState();
  }

  

  void _validateAndSave() async {
    if (courseName == null || courseName!.trim().isEmpty) {
      _showError("Please enter the course name.");
      return;
    }

    if (courseTitle == null || courseTitle!.trim().isEmpty) {
      _showError("Please enter the course code.");
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Create CourseSchedule if all schedule data is provided
      CourseSchedule? schedule;
      if (selectedDays.isNotEmpty &&
          startTime != null &&
          endTime != null &&
          location != null) {
        schedule = CourseSchedule(
          days: selectedDays,
          startTime: startTime!,
          endTime: endTime!,
          location: location!,
        );
      }

      // Convert UI color to CourseColor enum
      CourseColor courseColor = _colorToEnum(selectedColor);

      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("You must be logged in to create a course");
        return;
      }

      final courseRepository =
          CourseRepository(firestoreUtils: FirestoreUtils());

      // Print debug info
      print("Creating course with name: $courseName, code: $courseTitle");
      print("User ID: ${user.uid}");

      final newCourse = await courseRepository.createCourse(
        name: courseName!,
        code: courseTitle!,
        description:
            "Course Description", 
        color: courseColor,
        days: selectedDays.isNotEmpty ? selectedDays : null,
        startTime: startTime,
        endTime: endTime,
        location: location,
      );

      // Print confirmation
      print("Course created with ID: ${newCourse.id}");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Course created successfully!")),
      );

      // Navigate back to courses screen
      Navigator.pop(context);
    } catch (e) {
      // Print error details
      print("Error creating course: $e");
      _showError("Failed to create course: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  CourseColor _colorToEnum(Color color) {
    if (color == SLCColors.red) return CourseColor.red;
    if (color == SLCColors.green) return CourseColor.green;
    if (color == SLCColors.navyBlue) return CourseColor.blue;
    if (color == SLCColors.yellow) return CourseColor.yellow;
    if (color == SLCColors.purple) return CourseColor.purple;
    if (color == SLCColors.orange) return CourseColor.orange;
    if (color == Colors.black) return CourseColor.black;
    return CourseColor.blue; // Default
  }

  void _showError(String message) {
    SLCFlushbar.show(
        context: context, message: message, type: FlushbarType.error);
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.sizeOf(context).height;
    double screenwidth = MediaQuery.sizeOf(context).width;
    Orientation screenOrientation = MediaQuery.orientationOf(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              color: selectedColor,
              height: screenOrientation == Orientation.portrait
                  ? screenheight * 0.35
                  : screenheight * 0.5,
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
                        children: [
                          // Keep this row at the top
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
                                onPressed: _validateAndSave,
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SLCHeaderTextField(
                                  hintText: "Enter course name",
                                  fontSize: 35,
                                  fontWeight: FontWeight.w800,
                                  onChanged: (value) {
                                    setState(() {
                                      courseName = value;
                                    });
                                  },
                                ),
                                SLCHeaderTextField(
                                  hintText: "Enter course title",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  onChanged: (value) {
                                    setState(() {
                                      courseTitle = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SpacingStyles(context).defaultPadding.right,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenheight * 0.025),
                    Text("Color",
                        style: Theme.of(context).textTheme.headlineSmall),
                    SizedBox(height: 20),
                    SLCColorPicker(onColorSelected: (Color color) {
                      setState(() {
                        selectedColor = color;
                      });
                    }),
                    SizedBox(height: screenheight * 0.05),
                    Text("Days",
                        style: Theme.of(context).textTheme.headlineSmall),
                    SizedBox(height: 20),
                    SLCDayPicker(
                      onSelectionChanged: (days) {
                        setState(() {
                          selectedDays = days;
                        });
                      },
                    ),
                    SizedBox(height: screenheight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("Starts at",
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            SLCTimePicker(onTimeSelected: (time) {
                              setState(() {
                                startTime = time;
                              });
                            }),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Ends at",
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            SLCTimePicker(onTimeSelected: (time) {
                              setState(() {
                                endTime = time;
                              });
                            }),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: screenheight * 0.05),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Location",
                            style: Theme.of(context).textTheme.headlineSmall),
                        SizedBox(height: 20),
                        SLCTextField(
                          labelText: "",
                          onChanged: (value) {
                            setState(() {
                              location = value; // Optional, so no validation
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
