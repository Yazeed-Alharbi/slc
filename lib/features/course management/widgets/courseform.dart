import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/features/course%20management/widgets/slccolorpicker.dart';
import 'package:slc/features/course%20management/widgets/slcheadertextfield.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/features/course%20management/widgets/slctimepicker.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/repositories/course_repository.dart';

import 'slcdaypicker.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course;

  const CourseFormScreen({Key? key, this.course}) : super(key: key);

  @override
  _CourseFormScreenState createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  late CourseColor selectedColor;
  late TextEditingController nameController;
  late TextEditingController titleController;
  late TextEditingController locationController;
  List<String> selectedDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool _isLoading = false;
  bool get isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();

    // Initialize with course data if editing
    final course = widget.course;

    nameController = TextEditingController(text: course?.code ?? '');
    titleController = TextEditingController(text: course?.name ?? '');
    locationController =
        TextEditingController(text: course?.schedule?.location ?? '');

    selectedColor = course?.color ?? CourseColor.navyBlue;

    if (course?.schedule != null) {
      // Safely access days with null check
      selectedDays = course!.schedule!.days.isNotEmpty
          ? List<String>.from(course.schedule!.days)
          : [];
      startTime = course.schedule!.startTime;
      endTime = course.schedule!.endTime;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void _validateAndSave() async {
    // Validate form input
    if (nameController.text.trim().isEmpty) {
      _showError("Please enter the course code.");
      return;
    }

    if (titleController.text.trim().isEmpty) {
      _showError("Please enter the course title.");
      return;
    }

    if (selectedDays.isEmpty) {
      _showError("Please select at least one day.");
      return;
    }

    if (startTime == null) {
      _showError("Please select a start time.");
      return;
    }

    if (endTime == null) {
      _showError("Please select an end time.");
      return;
    }

    // Validate that end time is after start time
    final now = DateTime.now();
    final startDateTime = DateTime(
        now.year, now.month, now.day, startTime!.hour, startTime!.minute);
    final endDateTime =
        DateTime(now.year, now.month, now.day, endTime!.hour, endTime!.minute);

    if (endDateTime.isBefore(startDateTime)) {
      _showError("End time must be after start time.");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final courseRepository =
          CourseRepository(firestoreUtils: FirestoreUtils());
      final location = locationController.text.trim();

      // Check if we're editing or creating a new course
      if (isEditing) {
        // Update existing course
        await courseRepository.updateCourse(
          courseId: widget.course!.id,
          name: titleController.text,
          code: nameController.text,
          description: widget.course!.description,
          color: selectedColor,
        );

        // Update course schedule
        await courseRepository.updateCourseSchedule(
          courseId: widget.course!.id,
          days: selectedDays,
          startTime: startTime!,
          endTime: endTime!,
          location: location,
        );

        print("Course updated with ID: ${widget.course!.id}");
      } else {
        // Create new course
        final newCourse = await courseRepository.createCourse(
          name: titleController.text,
          code: nameController.text,
          description:
              "Course Description", // Consider adding description field
          color: selectedColor,
          days: selectedDays,
          startTime: startTime,
          endTime: endTime,
          location: location,
        );

        print("Course created with ID: ${newCourse.id}");
      }

      // Navigate back to previous screen
      if (mounted) {
        Navigator.pop(context, "success");
      }
    } catch (e) {
      print("Error ${isEditing ? 'updating' : 'creating'} course: $e");
      _showError("Failed to ${isEditing ? 'update' : 'create'} course: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    SLCFlushbar.show(
        context: context, message: message, type: FlushbarType.error);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;
    Orientation screenOrientation = MediaQuery.orientationOf(context);

    return Scaffold(
      body: _isLoading
          ? const SLCLoadingIndicator(text: "Saving course...")
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    color: SLCColors.getCourseColor(selectedColor),
                    height: screenOrientation == Orientation.portrait
                        ? screenHeight * 0.35
                        : screenHeight * 0.5,
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
                              horizontal:
                                  SpacingStyles(context).defaultPadding.right,
                            ),
                            child: Column(
                              children: [
                                // Top navigation row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        key: Key('submit_button'),
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Course name and title fields
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SLCHeaderTextField(
                                        controller: nameController,
                                        hintText: "Enter course code",
                                        fontSize: 35,
                                        key: const Key('course_name'),
                                        fontWeight: FontWeight.w800,
                                        onChanged: (value) {
                                          nameController.text = value;
                                        },
                                      ),
                                      SLCHeaderTextField(
                                        controller: titleController,
                                        hintText: "Enter course title",
                                        fontSize: 20,
                                        key: const Key('course_title'),
                                        fontWeight: FontWeight.w700,
                                        onChanged: (value) {
                                          titleController.text = value;
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
                          SizedBox(height: screenHeight * 0.025),
                          Text("Color",
                              style: Theme.of(context).textTheme.headlineSmall),
                          SizedBox(height: 20),
                          SLCColorPicker(
                              initialColor: selectedColor,
                              onColorSelected: (CourseColor color) {
                                setState(() {
                                  selectedColor = color;
                                });
                              }),
                          SizedBox(height: screenHeight * 0.05),
                          Text("Days",
                              style: Theme.of(context).textTheme.headlineSmall),
                          SizedBox(height: 20),
                          SLCDayPicker(
                            initialSelection: selectedDays,
                            onSelectionChanged: (days) {
                              setState(() {
                                selectedDays = days;
                              });
                            },
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Starts at",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  SLCTimePicker(
                                      initialTime: startTime,
                                      key: const ValueKey('start_time'),
                                      onTimeSelected: (time) {
                                        setState(() {
                                          startTime = time;
                                        });
                                      }),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Ends at",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  SLCTimePicker(
                                      initialTime: endTime,
                                      key: const ValueKey('end_time'),
                                      onTimeSelected: (time) {
                                        setState(() {
                                          endTime = time;
                                        });
                                      }),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Location",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              SizedBox(height: 20),
                              SLCTextField(
                                controller: locationController,
                                labelText: "Enter location",
                                onChanged: (value) {
                                  // The controller handles the value
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.1),
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
