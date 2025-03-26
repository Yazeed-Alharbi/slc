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
  // Default focus session duration in seconds (25 minutes)
  int _pomodoroMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _longBreakInterval = 4;
  int _duration = 25 * 60;
  bool _isPlaying = false;

  // Selected materials state
  final List<CourseMaterial> _selectedMaterials = [];
  static const int _maxMaterials = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _duration),
    );

    _controller.addListener(() {
      // Force UI to update by calling setState
      setState(() {
        // This empty setState is intentional - it forces a rebuild
        // when the animation value changes
      });

      if (_controller.isCompleted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
          pomodoroMinutes: _pomodoroMinutes,
          shortBreakMinutes: _shortBreakMinutes,
          longBreakMinutes: _longBreakMinutes,
          longBreakInterval: _longBreakInterval,
          onSave: (pomodoro, shortBreak, longBreak, interval) {
            setState(() {
              _pomodoroMinutes = pomodoro;
              _shortBreakMinutes = shortBreak;
              _longBreakMinutes = longBreak;
              _longBreakInterval = interval;

              // Update duration and reset the timer
              _duration = _pomodoroMinutes * 60;
              _controller.dispose();
              _controller = AnimationController(
                vsync: this,
                duration: Duration(seconds: _duration),
              );

              _isPlaying = false;
            });
          },
        );
      },
    );
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
              controller: _controller,
            ),

            SizedBox(height: screenHeight * 0.05),

            // Controls
            SLCButton(
              onPressed: _toggleTimer,
              backgroundColor: SLCColors.primaryColor,
              foregroundColor: Colors.white,
              text: _isPlaying ? "Pause" : "Start",
              width: 280,
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
                backgroundColor: SLCColors.primaryColor,
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
