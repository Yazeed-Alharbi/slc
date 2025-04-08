import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/features/focus%20sessions/widgets/animated_timer.dart';
import 'package:slc/features/focus%20sessions/services/focus_session_manager.dart';

class TimerDisplay extends StatefulWidget {
  final String mode;
  final bool isBreak;

  const TimerDisplay({
    Key? key,
    this.mode = "Focus Time",
    this.isBreak = false,
  }) : super(key: key);

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with SingleTickerProviderStateMixin {
  final FocusSessionManager _sessionManager = FocusSessionManager();
  static const String FOCUS_TIME = "25:00";
  static const String BREAK_TIME = "05:00";

  String? _timeRemaining;
  late Stream<int> _timerStream;
  bool _hasSessionStarted = false;

  // Add animation controller for smooth circle animation
  late AnimationController _progressAnimationController;
  // Remove 'late' to fix the error
  Animation<double>? _progressAnimation;
  double _currentProgress = 1.0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // IMMEDIATELY check if session is active and get EXACT current time
    // This is the key fix to prevent flashing the default time
    if (_sessionManager.isSessionActive) {
      _hasSessionStarted = true;
      _timeRemaining = _sessionManager.timeRemainingFormatted;

      // Also set the correct progress position
      if (_sessionManager.currentDuration > 0) {
        _currentProgress = 1.0 -
            (_sessionManager.elapsedSeconds / _sessionManager.currentDuration);
      }
    } else {
      // Only use default values if no active session
      _updateInitialTime();
    }

    // Listen for updates
    _timerStream = _sessionManager.timerStream;
    _timerStream.listen((_) {
      if (mounted) {
        _hasSessionStarted = true;
        _updateTimeString();
        _updateProgress();
      }
    });

    // Session manager listener
    _sessionManager.addListener(_handleSessionManagerChanges);
  }

  // New method that handles all session manager changes
  void _handleSessionManagerChanges() {
    if (!mounted) return;
    
    // Check if mode has changed (focus→break or break→focus)
    bool modeChanged = (_sessionManager.isBreakTime != widget.isBreak);
    
    // If session isn't active yet, update the initial time display
    if (!_sessionManager.isSessionActive) {
      _updateInitialTime();
    }
    
    // IMPORTANT: When switching between focus and break, reset progress circle to full
    if (modeChanged) {
      _currentProgress = 1.0;
      _progressAnimation = null;
      _progressAnimationController.value = 0;
      
      // Force an immediate update of the progress circle
      _updateProgress(animate: false);
    }
    
    // Always update the time string (which handles active sessions)
    _updateTimeString();
  }

  // New method to set the initial time based on current settings
  void _updateInitialTime() {
    // Use actual seconds from session manager
    final totalSeconds = widget.isBreak
        ? _sessionManager.shortBreakSeconds
        : _sessionManager.pomodoroFocusSeconds;

    // Format it properly
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    setState(() {
      _timeRemaining = '$minutes:$seconds';
    });
  }

  void _updateProgress({bool animate = true}) {
    double targetProgress;
    if (_sessionManager.elapsedSeconds == 0) {
      targetProgress = 1.0;
    } else {
      targetProgress = 1.0 -
          (_sessionManager.elapsedSeconds / _sessionManager.currentDuration);
    }

    // Don't set _currentProgress here yet - let the animation handle it

    // Always create an animation for smooth transitions
    _progressAnimation = Tween<double>(
      begin: _currentProgress, // Start from current position
      end: targetProgress, // Animate to target position
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // Make sure animation completes before updating the current progress
    _progressAnimationController.reset();
    _progressAnimationController.forward().then((_) {
      // Only update _currentProgress when animation completes
      _currentProgress = targetProgress;
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _sessionManager.removeListener(_handleSessionManagerChanges);
    super.dispose();
  }

  void _updateTimeString() {
    if (mounted) {
      setState(() {
        // Only use manager's time if we've started a session
        if (_sessionManager.isSessionActive || _hasSessionStarted) {
          _timeRemaining = _sessionManager.timeRemainingFormatted;
        }
      });
    }
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detect and handle mode changes (focus<->break) when widget rebuilds
    if (oldWidget.isBreak != widget.isBreak) {
      // Force reset progress circle and time display
      _currentProgress = 1.0;
      _updateInitialTime();
      
      // Force rebuild of the circle
      _progressAnimation = null;
      _progressAnimationController.value = 0;
      _updateProgress(animate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get color based on mode
    Color timerColor =
        widget.isBreak ? SLCColors.green : SLCColors.primaryColor;

    // We're ONLY using _timeRemaining which has been set correctly in initState
    final displayTime =
        _timeRemaining ?? ""; // Empty fallback instead of default

    return Center(
      child: Container(
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

            // Progress indicator with animation
            AnimatedBuilder(
              animation: _progressAnimationController,
              builder: (context, child) {
                return SizedBox(
                  width: 260,
                  height: 260,
                  child: CircularProgressIndicator(
                    // Always use the animated value when available
                    value: _progressAnimation?.value ?? _currentProgress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    color: timerColor,
                  ),
                );
              },
            ),

            // Time display
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedTimeDisplay(
                  timeString: displayTime,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _sessionManager.currentMode,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.isBreak ? SLCColors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
