import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/models/Course.dart';

class CourseTag extends StatelessWidget {
  final Course course;
  final int selectedCount;
  final VoidCallback? onTap;

  const CourseTag({
    Key? key,
    required this.course,
    this.selectedCount = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(
                  Icons.circle,
                  color: SLCColors.getCourseColor(course.color),
                ),
                if (selectedCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: SLCColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Center(
                        child: Text(
                          '$selectedCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 8),
            Text(
              course.code,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: SLCColors.getCourseColor(course.color).withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
