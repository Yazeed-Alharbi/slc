import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcbottomnavbar.dart';
import 'package:slc/features/calendar/screens/calendar.dart';
import 'package:slc/features/course%20management/screens/courses.dart';
import 'package:slc/features/home/screens/home.dart';
import 'package:slc/models/Student.dart';
import 'package:slc/main.dart'; // Import to access the global homeScreenKey

class MainLayout extends StatefulWidget {
  final Student student;
  const MainLayout({Key? key, required this.student}) : super(key: key);
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Simple list without conditional logic
    final List<Widget> widgetOptions = [
      HomeScreen(key: homeScreenKey, student: widget.student),
      CoursesScreen(student: widget.student),
      Center(child: Text('Page 3')),
      CalendarScreen(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: SLCBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
    );
  }
}
