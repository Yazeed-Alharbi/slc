import 'dart:async';
import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/features/focus%20sessions/screens/focussession.dart';
import 'package:slc/features/focus%20sessions/services/focus_session_manager.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

class _ActiveSessionCardState extends State<ActiveSessionCard>
    with WidgetsBindingObserver {
  final FocusSessionManager _sessionManager = FocusSessionManager();

  // For efficient UI updates
  late String _currentMode;
  late bool _isBreakTime;
  late String _timeRemaining;
  late StreamSubscription<int>? _timerSubscription;

  @override
  void initState() {
    super.initState();

    // Register as lifecycle observer to detect app resuming
    WidgetsBinding.instance.addObserver(this);

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
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    _timerSubscription?.cancel();
    _sessionManager.removeListener(_updateSessionState);
    super.dispose();
  }

  // Add this method to handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come back to foreground - recalculate elapsed time
      if (_sessionManager.isSessionActive && _sessionManager.isPlaying) {
        _sessionManager.recalculateElapsedTimeOnResume();

        // Update UI immediately
        if (mounted) {
          setState(() {
            _timeRemaining = _sessionManager.timeRemainingFormatted;
          });
        }
      }
    }
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
    final l10n = AppLocalizations.of(context);

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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sessionManager.isSessionActive
                        ? (l10n?.activeFocusSession ?? "Active Focus Session")
                        : (l10n?.focusSessionReady ?? "Focus Session Ready"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.course.code,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isBreakTime ? Icons.coffee : Icons.timer,
                        size: 16,
                        color: _isBreakTime ? SLCColors.green : courseColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _sessionManager.isSessionActive
                            // Use this to get translated mode instead of directly using _currentMode
                            ? "${_getLocalizedMode(context)}: $_timeRemaining"
                            : (l10n?.tapToStartSession ??
                                "Tap to start session"),
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

  // Add this helper method to get translated mode
  String _getLocalizedMode(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isBreakTime) {
      return l10n?.shortBreak ?? "Short Break";
    } else {
      return l10n?.focusTime ?? "Focus Time";
    }
  }
}
