import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';

class SLCBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const SLCBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(
            width: 0.25,
            color: Color.fromARGB(147, 127, 127, 127),
          ),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SpacingStyles(context).defaultPadding.right,
            vertical: 15.0),
        child: SafeArea(
          child: GNav(
            gap: 8,
            backgroundColor: Theme.of(context).colorScheme.surface,
            activeColor: Colors.white,
            color: const Color.fromARGB(147, 127, 127, 127),
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: SLCColors.primaryColor,
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.library_books, text: 'Courses'),
              GButton(icon: Icons.calendar_month_rounded, text: 'Calendar'),
              GButton(icon: Icons.settings, text: 'Settings'),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}
