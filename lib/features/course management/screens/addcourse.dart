import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slccolorpicker.dart';
import 'package:slc/common/widgets/slcheadertextfield.dart';
import 'package:slc/common/widgets/slctextfield.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  late Color selectedColor = SLCColors.primaryColor;
  @override
  void initState() {
    // TODO: implement initState
    selectedColor = SLCColors.primaryColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.sizeOf(context).height;
    double screenwidth = MediaQuery.sizeOf(context).width;
    Orientation screenOrientation = MediaQuery.orientationOf(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            color: selectedColor,
            height: screenOrientation == Orientation.portrait
                ? screenheight * 0.30
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
                        horizontal:
                            SpacingStyles(context).defaultPadding.right),
                    child: Column(
                      children: [
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
                              onPressed: () {},
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        SLCHeaderTextField(
                          hintText: "Enter course name",
                          fontSize: 35,
                          fontWeight: FontWeight.w800,
                        ),
                        SLCHeaderTextField(
                          hintText: "Enter course title",
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
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
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Color",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SLCColorPicker(
                        colors: [
                          SLCColors.primaryColor,
                          SLCColors.pastelGreen,
                          SLCColors.neonPink,
                          SLCColors.electricBlue,
                          SLCColors.pastelPink
                        ],
                        onColorSelected: (Color color) {
                          setState(() {
                            // handle color selection
                            selectedColor = color;
                          });
                        }),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
