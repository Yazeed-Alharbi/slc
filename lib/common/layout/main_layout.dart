import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcbottomnavbar.dart';
import 'package:slc/features/calendar/screens/calendar.dart';
import 'package:slc/features/course%20management/screens/courses.dart';
import 'package:slc/features/home/screens/home.dart';
import 'package:slc/models/Student.dart';
import 'package:slc/main.dart';

class MainLayout extends StatefulWidget {
  final Student student;
  final int initialIndex;

  const MainLayout({
    Key? key,
    required this.student,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Static variable to persist the selected index across rebuilds
  static int _persistedIndex = 0;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Use the persisted index or the provided initialIndex
    _selectedIndex =
        _persistedIndex != 0 ? _persistedIndex : widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Update the persisted index when user changes tabs
      _persistedIndex = index;
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
