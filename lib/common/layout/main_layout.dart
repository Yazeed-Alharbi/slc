import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcbottomnavrbar.dart';
import 'package:slc/features/home/screens/home.dart';


class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    Center(child: Text('Page 2')),
    Center(child: Text('Page 3')),
    Center(child: Text('Page 4')),
    Center(child: Text('Page 5')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], 
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          onPressed: () {
            _onItemTapped(2);
          },
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 48,
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SLCBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
