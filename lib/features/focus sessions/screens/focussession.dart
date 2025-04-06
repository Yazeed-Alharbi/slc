import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/features/course%20management/screens/coursepage.dart';
import 'package:slc/features/focus%20sessions/screens/aichat.dart';
import 'package:slc/features/focus%20sessions/screens/quiz.dart';
import 'package:slc/features/focus%20sessions/services/focus_session_manager.dart';
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
  final FocusSessionManager _sessionManager = FocusSessionManager();
  bool _initializedFromManager = false;

  // Keep list of selected materials in local state for UI
  List<CourseMaterial> _selectedMaterials = [];

  @override
  void initState() {
    super.initState();

    // Setup the animation controller for visual effects only
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _sessionManager.pomodoroFocusSeconds),
    );

    _initializeSession();

    // Listen to manager changes to update UI
    _sessionManager.addListener(_updateFromManager);
  }

  void _initializeSession() {
    // Check if there's an existing session for this course
    if (_sessionManager.isSessionActive &&
        _sessionManager.course.id == widget.course.id) {
      // Resume existing session
      _initializedFromManager = true;
      _selectedMaterials = _sessionManager.selectedMaterials;
      _updateControllerFromManager();
    } else {
      // Start new session
      _sessionManager.startSession(
        course: widget.course,
        enrollment: widget.enrollment,
        selectedMaterials: _selectedMaterials,
      );
    }
  }

  void _updateFromManager() {
    if (!mounted) {
      // Since we're not mounted anymore, clean up the listener
      _sessionManager.removeListener(_updateFromManager);
      return;
    }

    setState(() {
      _selectedMaterials = _sessionManager.selectedMaterials;
      _updateControllerFromManager();

      // Timer display updates via the controller
    });

    // Handle session completion
    if (_sessionManager.sessionCompleted) {
      _showQuizModal();
    }
  }

  void _updateControllerFromManager() {
    // Update animation controller to match manager state
    final duration = _sessionManager.currentDuration;
    final elapsed =
        _sessionManager.isSessionActive ? _sessionManager.elapsedSeconds : 0;

    _controller.duration = Duration(seconds: duration);

    if (elapsed > 0 && elapsed < duration) {
      // Set controller to correct position
      _controller.value = elapsed / duration;

      // Resume controller animation if session is playing
      if (_sessionManager.isPlaying) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    } else if (elapsed >= duration) {
      _controller.value = 1.0;
    } else {
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sessionManager.removeListener(_updateFromManager);
    super.dispose();
  }

  void _toggleTimer() {
    if (_sessionManager.isPlaying) {
      _sessionManager.pauseTimer();
      _controller.stop();
    } else {
      _sessionManager.startTimer();
      if (_controller.value == 1.0) {
        _controller.reset();
      }
      _controller.forward();
    }
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
          pomodoroMinutes: (_sessionManager.pomodoroFocusSeconds / 60).round(),
          shortBreakMinutes: (_sessionManager.shortBreakSeconds / 60).round(),
          longBreakMinutes: (_sessionManager.longBreakSeconds / 60).round(),
          longBreakInterval: _sessionManager.totalPomodoros,
          onSave: (pomodoro, shortBreak, longBreak, interval) {
            _sessionManager.updateSettings(
              pomodoro: pomodoro,
              shortBreak: shortBreak,
              longBreak: longBreak,
              interval: interval,
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showMaterialSelectionDialog({Function()? onSelectionComplete}) {
    if (widget.course.materials.isEmpty) {
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
          maxMaterials: 5, // Keep constant
          onMaterialsUpdated: (materials) {
            _selectedMaterials = materials;
            _sessionManager.updateMaterials(materials);

            // This block is only executed when the dialog was launched from the quiz flow.
            if (onSelectionComplete != null) {
              if (materials.isNotEmpty) {
                // Materials were selected: auto-close the dialog and trigger callback.
                Navigator.of(context).pop();
                // Use a microtask so that the pop is fully processed before navigating.
                Future.microtask(() => onSelectionComplete());
              }
            }
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

  void _navigateToQuiz() {
    if (_selectedMaterials.isEmpty) {
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
                  "You've completed ${_sessionManager.totalPomodoros} pomodoros!",
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
                      onPressed: _navigateToQuiz,
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
              key: ValueKey(_controller),
              controller: _controller,
              mode: _sessionManager.currentMode,
              isBreak: _sessionManager.isBreakTime,
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
                    "Session: ${_sessionManager.completedPomodoros}",
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
                    onPressed:
                        _sessionManager.sessionCompleted ? null : _toggleTimer,
                    backgroundColor: _sessionManager.isBreakTime
                        ? SLCColors.green
                        : SLCColors.primaryColor,
                    foregroundColor: Colors.white,
                    text: _sessionManager.isPlaying
                        ? "Pause"
                        : (_sessionManager.sessionCompleted
                            ? "Completed"
                            : "Start"),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Session status indicator
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
            mode: _sessionManager.currentMode,
            isBreak: _sessionManager.isBreakTime,
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
                onPressed:
                    _sessionManager.sessionCompleted ? null : _toggleTimer,
                backgroundColor: _sessionManager.isBreakTime
                    ? SLCColors.green
                    : SLCColors.primaryColor,
                foregroundColor: Colors.white,
                text: _sessionManager.isPlaying
                    ? "Pause"
                    : (_sessionManager.sessionCompleted
                        ? "Completed"
                        : "Start"),
                width: 280,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
