import 'package:flutter/material.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/widgets/slceventcard.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greeting = "";

  @override
  void initState() {
    super.initState();
    _updateGreeting();
  }

  void _updateGreeting() {
    final int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good Evening";
    } else {
      greeting = "Hello";
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'logout':
        _logoutUser();
        break;
    }
  }

  void _logoutUser() {
    Navigator.pushReplacementNamed(context, '/loginscreen');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: SpacingStyles(context).defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "Yazeed Alharbi",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                PullDownButton(
                  itemBuilder: (context) => [
                    PullDownMenuItem(
                      onTap: () => {},
                      title: "Settings",
                      icon: Icons.settings,
                    ),
                    PullDownMenuItem(
                      onTap: () => _handleMenuSelection('logout'),
                      title: "Logout",
                      isDestructive: true,
                      icon: Icons.logout,
                    ),
                  ],
                  buttonBuilder: (context, showMenu) => GestureDetector(
                    onTap: showMenu,
                    child: SLCAvatar(
                      size: 55,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.05,
                    ),
                    Text(
                      "Events",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SLCEventCard(
                      title: "SWE 387",
                      location: "20-130",
                      startTime: TimeOfDay(hour: 9, minute: 0),
                      endTime: TimeOfDay(hour: 9, minute: 50),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SLCEventCard(
                      title: "ICS 253",
                      location: "20-130",
                      startTime: TimeOfDay(hour: 9, minute: 0),
                      endTime: TimeOfDay(hour: 9, minute: 50),
                      color: EventCardColor.green,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SLCEventCard(
                        title: "MATH 208",
                        location: "20-130",
                        startTime: TimeOfDay(hour: 9, minute: 0),
                        endTime: TimeOfDay(hour: 9, minute: 50),
                        color: EventCardColor.black),
                    SizedBox(
                      height: 20,
                    ),
                    SLCEventCard(
                      title: "Midterm",
                      location: "54",
                      startTime: TimeOfDay(hour: 9, minute: 0),
                      endTime: TimeOfDay(hour: 10, minute: 50),
                      color: EventCardColor.white,
                      pinnedText: "ICS 253",
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
