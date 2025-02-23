import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';
import 'package:slc/features/course%20management/widgets/slccoursecard.dart';
import 'package:slc/common/widgets/slciconbutton.dart';
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
    double _screenWidth = MediaQuery.sizeOf(context).width;
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
                                  Navigator.pushNamed(context, "/addcourse");
                                },
                                backgroundColor: SLCColors.primaryColor,
                                iconColor: Colors.white,
                                icon: Icons.add)
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          color: EventCardColor.blue,
                          title: "SWE 38729829892892",
                          name: "Software Project Management",
                          notifications: ["Midterm", "Homework 3", "22", "33"],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          title: "ICS 253",
                          name: "Discrete Structures",
                          color: EventCardColor.green,
                          notifications: [],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          title: "MATH 208",
                          color: EventCardColor.black,
                          name: "Differential Equations & Linear Algebra",
                          notifications: [],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SLCCourseCard(
                          title: "SWE 316",
                          color: EventCardColor.yellow,
                          name: "Software Design And Construction",
                          notifications: [],
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
