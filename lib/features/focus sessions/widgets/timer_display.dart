import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/features/focus%20sessions/widgets/animated_timer.dart';

class TimerDisplay extends StatefulWidget {
  final AnimationController controller;
  final String mode;
  final bool isBreak;

  const TimerDisplay({
    Key? key,
    required this.controller,
    this.mode = "Focus Time",
    this.isBreak = false,
  }) : super(key: key);

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  String _timeRemaining = "00:00";
  AnimationController? _previousController;

  @override
  void initState() {
    super.initState();
    _setupControllerListener();
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_updateTimeString);
      _setupControllerListener();
    }
  }

  void _setupControllerListener() {
    _updateTimeString();
    widget.controller.addListener(_updateTimeString);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTimeString);
    super.dispose();
  }

  void _updateTimeString() {
    final duration =
        widget.controller.duration! * (1 - widget.controller.value);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    setState(() {
      _timeRemaining = '$minutes:$seconds';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get color based on mode
    Color timerColor =
        widget.isBreak ? SLCColors.green : SLCColors.primaryColor;

    return Center(
      child: AnimatedBuilder(
        animation: widget.controller,
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
                    value: 1.0 - widget.controller.value,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    color: timerColor,
                  ),
                ),
                // Time display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedTimeDisplay(
                      timeString: _timeRemaining,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.mode,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            widget.isBreak ? SLCColors.green : Colors.grey[600],
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
