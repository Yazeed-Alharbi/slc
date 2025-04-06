import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';
import 'package:slc/features/focus%20sessions/screens/aichat.dart';
import 'package:slc/features/focus%20sessions/screens/quiz.dart';
import 'package:slc/features/focus%20sessions/widgets/course_tag.dart';
import 'package:slc/features/focus%20sessions/widgets/focus_menu_button.dart';
import 'package:slc/features/focus%20sessions/widgets/material_selection_dialog.dart';
import 'package:slc/features/focus%20sessions/widgets/settings_dialog.dart';
import 'package:slc/features/focus%20sessions/widgets/timer_display.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/Material.dart';
import 'package:slc/models/course_enrollment.dart';

class FocusSessionScreen extends StatefulWidget {
  final Course course;
  final CourseEnrollment enrollment;

  const FocusSessionScreen(
      {super.key, required this.course, required this.enrollment});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _controllerDisposed = false; // Track disposal

  // Replace testing values with defaults.
  int _pomodoroFocusSeconds = 25 * 60; // 25 minutes of focus
  int _shortBreakSeconds = 5 * 60; // 5 minutes short break
  int _longBreakSeconds = 15 * 60; // 15 minutes long break
  // _longBreakInterval can remain at 4 (or your preferred value)
  int _totalPomodoros = 4;

  int _duration = 5;
  bool _isPlaying = false;

  // Pomodoro cycle tracking
  int _completedPomodoros = 0;
  String _currentMode = "Focus Time";
  bool _isBreakTime = false;

  // Selected materials state...
  final List<CourseMaterial> _selectedMaterials = [];
  static const int _maxMaterials = 5;

  // First, add a boolean to track if the session is completed
  bool _sessionCompleted = false;

  @override
  void initState() {
    super.initState();
    _duration = _pomodoroFocusSeconds;
    _currentMode = "Focus Time";
    _setupController();
  }

  void _setupController() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _duration),
    );
    // Reset the flag when creating a new controller.
    _controllerDisposed = false;

    _controller.addListener(() {
      setState(() {});
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleTimerCompleted();
      }
    });
  }

  // Helper method to dispose controller once.
  void _disposeController() {
    if (!_controllerDisposed) {
      _controller.dispose();
      _controllerDisposed = true;
    }
  }

  void _transitionToNextPhase({bool resetToFocus = false}) {
    setState(() {
      if (resetToFocus) {
        _isBreakTime = false;
        _currentMode = "Focus Time";
        _duration = _pomodoroFocusSeconds;
      } else if (!_isBreakTime) {
        // Transitioning from focus to break
        _completedPomodoros++;

        if (_completedPomodoros == _totalPomodoros) {
          _sessionCompleted = true;
          _disposeController();
          _showQuizModal();
          return;
        } else {
          _isBreakTime = true;
          _currentMode = "Short Break";
          _duration = _shortBreakSeconds;
        }
      } else {
        // Transitioning from break to focus
        _isBreakTime = false;
        _currentMode = "Focus Time";
        _duration = _pomodoroFocusSeconds;
      }

      _disposeController();
      _setupController();
      _isPlaying = false;
    });
  }

  void _handleTimerCompleted() {
    _transitionToNextPhase();
  }

  void _navigateToQuiz() {
    if (_selectedMaterials.isEmpty) {
      // No materials selected: prompt selection with callback
      _showMaterialSelectionDialog(
        onSelectionComplete: () {
          Navigator.pop(context); // Close the quiz modal
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                course: widget.course,
                selectedMaterials: _selectedMaterials,
              ),
            ),
          );
        },
      );
    } else {
      // Materials already selected: navigate directly
      Navigator.pop(context); // Close quiz modal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            course: widget.course,
            selectedMaterials: _selectedMaterials,
          ),
        ),
      );
    }
  }

  void _showQuizModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You've completed $_totalPomodoros pomodoros!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Would you like to take a quiz about the material?",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    SLCButton(
                      onPressed: _sessionCompleted ? _navigateToQuiz : null,
                      backgroundColor: SLCColors.primaryColor,
                      foregroundColor: Colors.white,
                      text: "Take the Quiz",
                    ),
                    SLCButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.transparent,
                      foregroundColor: SLCColors.primaryColor,
                      text: "Skip",
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  String get timeRemaining {
    final duration = _controller.duration! * (1 - _controller.value);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleTimer() {
    if (_isPlaying) {
      _controller.stop();
    } else {
      if (_controller.value == 1.0) {
        _controller.reset();
      }
      _controller.forward();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _resetTimer() {
    setState(() {
      _controller.reset();
      _isPlaying = false;
    });
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SettingsDialog(
          pomodoroMinutes: (_pomodoroFocusSeconds / 60).round(),
          shortBreakMinutes: (_shortBreakSeconds / 60).round(),
          longBreakMinutes: (_longBreakSeconds / 60).round(),
          longBreakInterval: _totalPomodoros,
          onSave: (pomodoro, shortBreak, longBreak, interval) {
            setState(() {
              // Convert minutes to seconds.
              _pomodoroFocusSeconds = pomodoro * 60;
              _shortBreakSeconds = shortBreak * 60;
              _longBreakSeconds = longBreak * 60;
              _totalPomodoros = interval;
            });

            // Use the transition helper with resetToFocus=true to properly
            // reset the timer with the new settings
            _transitionToNextPhase(resetToFocus: true);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // Fix the _showMaterialSelectionDialog method
  void _showMaterialSelectionDialog({Function()? onSelectionComplete}) {
    if (widget.course.materials.isEmpty) {
      // Show message if no materials are available
      SLCFlushbar.show(
          context: context,
          message: "No materials are available for this course.",
          type: FlushbarType.error);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return MaterialSelectionDialog(
          course: widget.course,
          selectedMaterials: _selectedMaterials,
          maxMaterials: _maxMaterials,
          onMaterialsUpdated: (materials) {
            setState(() {
              _selectedMaterials.clear();
              _selectedMaterials.addAll(materials);
            });

            // This block is only executed when the dialog was launched from the quiz flow.
            if (onSelectionComplete != null) {
              if (materials.isNotEmpty) {
                // Materials were selected: auto-close the dialog and trigger callback.
                Navigator.of(context).pop();
                // Use a microtask so that the pop is fully processed before navigating.
                Future.microtask(() => onSelectionComplete());
              }
            }
            // Otherwise (normal selection outside quiz flow) simply update _selectedMaterials without auto-closing.
          },
        );
      },
    );
  }

  void _navigateToAiChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AiChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Padding(
                padding: SpacingStyles(context).defaultPadding,
                child: orientation == Orientation.portrait
                    ? _buildPortraitLayout(context)
                    : _buildLandscapeLayout(context));
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top menu
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FocusMenuButton(
              onSettingsTap: _showSettingsDialog,
              onAIAssistantTap: _navigateToAiChat,
            ),
          ],
        ),

        SizedBox(height: screenHeight * 0.05),

        // Course tag
        CourseTag(
          course: widget.course,
          selectedCount: _selectedMaterials.length,
          onTap: _showMaterialSelectionDialog,
        ),

        SizedBox(height: screenHeight * 0.05),

        // Timer and controls
        Column(
          children: [
            TimerDisplay(
              key: ValueKey(
                  _controller), // Adds a Key based on the current controller instance
              controller: _controller,
              mode: _currentMode,
              isBreak: _isBreakTime,
            ),

            SizedBox(height: screenHeight * 0.05),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show session count
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "Session: ${_completedPomodoros}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                // Main button
                SizedBox(
                  width: 220,
                  child: SLCButton(
                    onPressed: _sessionCompleted
                        ? null
                        : _toggleTimer, // Disable if completed
                    backgroundColor:
                        _isBreakTime ? SLCColors.green : SLCColors.primaryColor,
                    foregroundColor: Colors.white,
                    text: _isPlaying
                        ? "Pause"
                        : (_sessionCompleted ? "Completed" : "Start"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        // Timer on left side (taking half the width)
        Expanded(
          child: TimerDisplay(
            controller: _controller,
            mode: _currentMode,
            isBreak: _isBreakTime,
          ),
        ),

        const SizedBox(width: 24),

        // Controls on right side
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FocusMenuButton(
                      onSettingsTap: _showSettingsDialog,
                      onAIAssistantTap: _navigateToAiChat),
                ],
              ),
              const SizedBox(height: 24),
              CourseTag(
                course: widget.course,
                selectedCount: _selectedMaterials.length,
                onTap: _showMaterialSelectionDialog,
              ),
              const SizedBox(height: 40),
              SLCButton(
                onPressed: _sessionCompleted
                    ? null
                    : _toggleTimer, // Disable if completed
                backgroundColor:
                    _isBreakTime ? SLCColors.green : SLCColors.primaryColor,
                foregroundColor: Colors.white,
                text: _isPlaying
                    ? "Pause"
                    : (_sessionCompleted ? "Completed" : "Start"),
                width: 280,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
