import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/features/course%20management/screens/filestab.dart';

class CourseScreen extends StatefulWidget {
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late Color selectedColor;

  @override
  void initState() {
    selectedColor = SLCColors.navyBlue;
    super.initState();
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
              color: selectedColor,
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
                                onPressed: () {}, // Add validation logic here
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
                                "SWE 387",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.w800,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "Software Project Management",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SLCButton(
                            onPressed: () {},
                            width: screenwidth * 0.2,
                            text: "Start Focus Session",
                            backgroundColor: Colors.white,
                            foregroundColor: selectedColor,
                            icon: Icon(
                              Icons.play_circle,
                              color: selectedColor,
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
                    dividerColor: Color.fromARGB(147, 127, 127, 127),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: [
                      Tab(text: "Files"),
                      Tab(text: "Notes"),
                      Tab(text: "Events"),
                    ],
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        FilesTab(),
                        Center(child: Text("Notes Content")),
                        Center(child: Text("Events Content")),
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
}
