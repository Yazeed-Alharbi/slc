import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';

class SLCBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const SLCBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(15, 0, 0, 0),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, -1), 
          ),
        ],
      ),
      child: BottomAppBar(
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.library_books_sharp, 1),
              SizedBox(width: 40),
              _buildNavItem(Icons.people_alt_outlined, 3),
              _buildNavItem(Icons.calendar_month_outlined, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      highlightColor: Colors.transparent,
      icon: Icon(
        icon,
        size: 30,
        color: selectedIndex == index
            ? SLCColors.primaryColor
            : const Color.fromARGB(108, 158, 158, 158),
      ),
      onPressed: () => onItemTapped(index),
    );
  }
}
