import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcbottomnavbar.dart';
import 'package:slc/features/course%20management/screens/courses.dart';
import 'package:slc/features/home/screens/home.dart';
import 'package:slc/models/Student.dart';

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
    List<Widget> widgetOptions = <Widget>[
      HomeScreen(student: widget.student),
      CoursesScreen(student: widget.student),
      Center(child: Text('Page 3')),
      Center(child: Text('Page 4')),
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
