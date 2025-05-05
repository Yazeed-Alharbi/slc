import 'package:flutter/material.dart';
import 'package:slc/features/course%20management/widgets/courseform.dart';

class AddCourseScreen extends StatelessWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simply render the CourseFormScreen without passing a course (for adding mode)
    return const CourseFormScreen();
  }
}
