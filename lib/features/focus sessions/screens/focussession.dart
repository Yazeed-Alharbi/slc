import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
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
import 'package:slc/services/notifications_service.dart';

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
  bool _quizModalShown = false;

  // Keep list of selected materials in local state for UI
  List<CourseMaterial> _selectedMaterials = [];

  @override
  void initState() {
    super.initState();

    // Request notification permissions
    _requestNotificationPermissions();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _sessionManager.currentDuration),
    );

    // Subscribe to session manager updates
    _sessionManager.addListener(_updateFromManager);

    // Call this method to initialize the session
    _initializeSession();
  }

  Future<void> _requestNotificationPermissions() async {
    // Store a flag to only show this once
    final prefs = await SharedPreferences.getInstance();
    bool hasRequestedPermissions = prefs.getBool('notification_permissions_requested') ?? false;
    
    if (!hasRequestedPermissions) {
      await NotificationsService().requestNotificationPermissions();
      await prefs.setBool('notification_permissions_requested', true);
    }
  }

  void _initializeSession() {
    // Check if there's an existing session for this course
    if (_sessionManager.isSessionActive &&
        _sessionManager.course.id == widget.course.id) {
      // Resume existing session
      _initializedFromManager = true;
      _selectedMaterials = _sessionManager.selectedMaterials;
      _updateControllerFromManager();

      // Check if session is already completed and show quiz modal if needed
      if (_sessionManager.sessionCompleted && !_quizModalShown) {
        // Set flag to prevent duplicate modals
        _quizModalShown = true;

        // Delay showing the modal until after the build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showQuizModal();
          }
        });
      }
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
      // Update state variables from manager
      _selectedMaterials = _sessionManager.selectedMaterials;
    });

    // Handle session completion - show quiz modal when session is marked as completed
    if (_sessionManager.sessionCompleted && !_quizModalShown) {
      // Set flag to prevent duplicate modals
      _quizModalShown = true;

      // Use a post-frame callback to avoid showing during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showQuizModal();
        }
      });
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
                      onPressed: () {
                        // End session before navigating to quiz
                        _sessionManager.endSession();
                        _navigateToQuiz();
                      },
                      backgroundColor: SLCColors.primaryColor,
                      foregroundColor: Colors.white,
                      text: "Take the Quiz",
                    ),
                    SLCButton(
                      onPressed: () {
                        // End session when skipping quiz
                        _sessionManager.endSession();
                        Navigator.of(context).popUntil((route) {
                          // Either pop until we reach the home route or until we reach the root
                          return route.isFirst;
                        });
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

  // Handle back button press
  void _handleBackButtonPress() {
    // If session is active, show confirmation dialog

    // Just go back if session is paused - it will still be shown in home
    Navigator.pop(context);
  }

  // Show confirmation dialog for ending session
  void _showEndSessionConfirmation() {
    NativeAlertDialog.show(
      context: context,
      title: "End Session",
      content: "Are you sure you want to end this session?",
      confirmText: "End Session",
      confirmTextColor: Colors.red,
      cancelText: "Cancel",
      onConfirm: () {
        _sessionManager.endSession();
        Navigator.pop(context);
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
        // Top menu with back button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBackButtonPress(),
            ),

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
                    "Session: ${_sessionManager.completedPomodoros}/${_sessionManager.totalPomodoros}",
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

            // End Session button - only visible when session is active
            if (_sessionManager.isSessionActive) ...[
              SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: SLCButton(
                  onPressed: _showEndSessionConfirmation,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  text: "End Session",
                ),
              ),
            ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _handleBackButtonPress(),
                  ),

                  FocusMenuButton(
                    onSettingsTap: _showSettingsDialog,
                    onAIAssistantTap: _navigateToAiChat,
                  ),
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

              // End Session button - visible only when active
              if (_sessionManager.isSessionActive) ...[
                const SizedBox(height: 16),
                SLCButton(
                  onPressed: _showEndSessionConfirmation,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  text: "End Session",
                  width: 280,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
