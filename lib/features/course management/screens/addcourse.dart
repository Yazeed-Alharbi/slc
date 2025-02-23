import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/features/course%20management/widgets/slccolorpicker.dart';
import 'package:slc/features/course%20management/widgets/slcheadertextfield.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/features/course%20management/widgets/slctimepicker.dart';
import 'package:slc/common/widgets/slcflushbar.dart';

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

  @override
  void initState() {
    selectedColor = SLCColors.navyBlue;
    super.initState();
  }

  void _validateAndSave() {
    if (courseName == null || courseName!.trim().isEmpty) {
      _showError("Please enter the course name.");
      return;
    }
    if (courseTitle == null || courseTitle!.trim().isEmpty) {
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

    // ✅ All validations passed, proceed with saving
    print("Course saved successfully!");
    Navigator.pop(context);
  }

  void _showError(String message) {
    SLCFlushbar.show(context: context, message: message, type: FlushbarType.error);
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
