import 'dart:async';
import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/features/focus%20sessions/screens/focussession.dart';
import 'package:slc/features/focus%20sessions/services/focus_session_manager.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';

class ActiveSessionCard extends StatefulWidget {
  final Course course;
  final CourseEnrollment enrollment;
  final Function()? onTap;

  const ActiveSessionCard({
    Key? key,
    required this.course,
    required this.enrollment,
    this.onTap,
  }) : super(key: key);

  @override
  State<ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<ActiveSessionCard> {
  final FocusSessionManager _sessionManager = FocusSessionManager();

  // For efficient UI updates
  late String _currentMode;
  late bool _isBreakTime;
  late String _timeRemaining;
  late StreamSubscription<int>? _timerSubscription;

  @override
  void initState() {
    super.initState();

    // Initial values
    _currentMode = _sessionManager.currentMode;
    _isBreakTime = _sessionManager.isBreakTime;
    _timeRemaining = _sessionManager.timeRemainingFormatted;

    // Listen for major state changes
    _sessionManager.addListener(_updateSessionState);

    // Listen to timer ticks
    _timerSubscription = _sessionManager.timerStream.listen((_) {
      if (mounted) {
        setState(() {
          _timeRemaining = _sessionManager.timeRemainingFormatted;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _sessionManager.removeListener(_updateSessionState);
    super.dispose();
  }

  void _updateSessionState() {
    if (!mounted) return;

    setState(() {
      _currentMode = _sessionManager.currentMode;
      _isBreakTime = _sessionManager.isBreakTime;
      _timeRemaining = _sessionManager.timeRemainingFormatted;
    });
  }

  void _updateTimerDisplay(int _) {
    if (!mounted) return;

    setState(() {
      _timeRemaining = _sessionManager.timeRemainingFormatted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color courseColor = SLCColors.getCourseColor(widget.course.color);

    return GestureDetector(
      onTap: widget.onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FocusSessionScreen(
                  course: widget.course,
                  enrollment: widget.enrollment,
                ),
              ),
            );
          },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 70,
              decoration: BoxDecoration(
                color: courseColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sessionManager.isSessionActive
                        ? "Active Focus Session"
                        : "Focus Session Ready",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.course.code,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isBreakTime ? Icons.coffee : Icons.timer,
                        size: 16,
                        color: _isBreakTime ? SLCColors.green : courseColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _sessionManager.isSessionActive
                            ? "$_currentMode: $_timeRemaining"
                            : "Tap to start session",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isBreakTime ? SLCColors.green : courseColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
