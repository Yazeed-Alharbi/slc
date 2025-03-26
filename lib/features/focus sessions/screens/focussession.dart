import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/features/focus%20sessions/widgets/course_tag.dart';
import 'package:slc/features/focus%20sessions/widgets/focus_menu_button.dart';
import 'package:slc/features/focus%20sessions/widgets/material_selection_dialog.dart';
import 'package:slc/features/focus%20sessions/widgets/settings_dialog.dart';
import 'package:slc/features/focus%20sessions/widgets/timer_display.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/Material.dart';

class FocusSessionScreen extends StatefulWidget {
  final Course course;

  const FocusSessionScreen({
    super.key,
    required this.course,
  });

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _controllerDisposed = false; // Track disposal

  // For testing, define durations in seconds.
  int _pomodoroFocusSeconds = 1;
  int _shortBreakSeconds = 1;
  int _longBreakSeconds = 1;
  int _duration = 5;
  bool _isPlaying = false;

  // Pomodoro cycle tracking
  int _completedPomodoros = 0;
  String _currentMode = "Focus Time";
  bool _isBreakTime = false;
  int _longBreakInterval = 4;

  // Selected materials state...
  final List<CourseMaterial> _selectedMaterials = [];
  static const int _maxMaterials = 5;

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

  void _handleTimerCompleted() {
    setState(() {
      _isPlaying = false;
      if (!_isBreakTime) {
        _completedPomodoros++;
        if (_completedPomodoros == _longBreakInterval) {
          _disposeController();
          _showQuizModal();
          return;
        } else {
          _isBreakTime = true;
          _duration = _shortBreakSeconds;
          _currentMode = "Short Break";
        }
      } else {
        _isBreakTime = false;
        _duration = _pomodoroFocusSeconds;
        _currentMode = "Focus Time";
      }
      _disposeController();
      _setupController();
    });
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
                  "You've completed 4 pomodoros!",
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Scaffold(body: Center(child: Text("Quiz")))),
                        );
                      },
                      backgroundColor: SLCColors.primaryColor,
                      foregroundColor: Colors.white,
                      text: "Take the Quiz",
                    ),
                    SLCButton(
                      onPressed: () {
                        Navigator.pop(context); // close modal
                        Navigator.pop(context); // close focus session screen
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
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    //   ),
    //   builder: (BuildContext context) {
    //     return SettingsDialog(
    //       pomodoroMinutes: _pomodoroMinutes,
    //       shortBreakMinutes: _shortBreakMinutes,
    //       longBreakMinutes: _longBreakMinutes,
    //       longBreakInterval: _longBreakInterval,
    //       onSave: (pomodoro, shortBreak, longBreak, interval) {
    //         setState(() {
    //           _pomodoroMinutes = pomodoro;
    //           _shortBreakMinutes = shortBreak;
    //           _longBreakMinutes = longBreak;
    //           _longBreakInterval = interval;

    //           // Update duration and reset the timer
    //           _duration = _pomodoroMinutes * 60;
    //           _controller.dispose();
    //           _controller = AnimationController(
    //             vsync: this,
    //             duration: Duration(seconds: _duration),
    //           );

    //           _isPlaying = false;
    //         });
    //       },
    //     );
    //   },
    // );
  }

  void _showMaterialSelectionDialog() {
    if (widget.course.materials.isEmpty) {
      // Show message if no materials are available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No materials available for this course')),
      );
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
          },
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
                    onPressed: _toggleTimer,
                    backgroundColor:
                        _isBreakTime ? SLCColors.green : SLCColors.primaryColor,
                    foregroundColor: Colors.white,
                    text: _isPlaying ? "Pause" : "Start",
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
                onPressed: _toggleTimer,
                backgroundColor:
                    _isBreakTime ? SLCColors.green : SLCColors.primaryColor,
                foregroundColor: Colors.white,
                text: _isPlaying ? "Pause" : "Start",
                width: 280,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
