import 'package:flutter/material.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/widgets/slccoursecard.dart';
import 'package:slc/common/widgets/slcquickactioncard.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: SpacingStyles(context).defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Courses",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 30),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          color: EventCardColor.blue,
                          title: "SWE 387",
                          name: "Software Project Management",
                          notification1: "",
                          notification2: "",
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          title: "ICS 253",
                          name: "Discrete Structures",
                          color: EventCardColor.green,
                          notification1: "Midterm",
                          notification2: "Homework 3",
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          title: "MATH 208",
                          color: EventCardColor.black,
                          name: "Differential Equations & Linear Algebra",
                          notification1: "",
                          notification2: "",
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          title: "SWE 316",
                          color: EventCardColor.yellow,
                          name: "Software Design And Construction",
                          notification1: "",
                          notification2: "",
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
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
