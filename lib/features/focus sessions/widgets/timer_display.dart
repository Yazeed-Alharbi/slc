import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/features/focus%20sessions/widgets/animated_timer.dart';

class TimerDisplay extends StatelessWidget {
  final AnimationController controller;
  final String timeRemaining;
  
  const TimerDisplay({
    Key? key,
    required this.controller,
    required this.timeRemaining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular background
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
                // Progress indicator
                SizedBox(
                  width: 260,
                  height: 260,
                  child: CircularProgressIndicator(
                    value: 1.0 - controller.value,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    color: SLCColors.primaryColor,
                  ),
                ),
                // Time display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedTimeDisplay(
                      timeString: timeRemaining,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Focus Time",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}