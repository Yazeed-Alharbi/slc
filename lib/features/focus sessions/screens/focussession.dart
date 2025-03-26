import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slciconbutton.dart';
import 'package:slc/features/focus%20sessions/widgets/animated_timer.dart';
import 'package:slc/features/focus%20sessions/widgets/timer_display.dart';
import 'package:slc/features/focus%20sessions/widgets/settings_dialog.dart';

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _duration),
    );

    _controller.addListener(() {
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
    setState(() {
      if (_isPlaying) {
        _controller.stop();
      } else {
        if (_controller.value == 1.0) {
          _controller.reset();
        }
        _controller.forward();
      }
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
    double _screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top menu
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildMenuButton()],
        ),

        SizedBox(height: _screenHeight * 0.05),

        // Course tag
        _buildCourseTag(),

        SizedBox(height: _screenHeight * 0.05),

        // Timer (expanded to take available space)

        Column(
          children: [
            TimerDisplay(
              controller: _controller,
              timeRemaining: timeRemaining,
            ),

            SizedBox(height: _screenHeight * 0.05),

            // Controls
            _buildControlButton(),
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
            timeRemaining: timeRemaining,
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
                children: [_buildMenuButton()],
              ),
              const SizedBox(height: 24),
              _buildCourseTag(),
              const SizedBox(height: 40),
              _buildControlButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () => () {},
          title: "Notes",
          icon: Icons.note_alt,
        ),
        PullDownMenuItem(
          onTap: () => () {},
          title: "AI Assistant",
          icon: Icons.chat,
        ),
        PullDownMenuItem(
          onTap: () => _showSettingsDialog(),
          title: "Settings",
          icon: Icons.settings,
        ),
      ],
      buttonBuilder: (context, showMenu) => GestureDetector(
        onTap: showMenu,
        child: Icon(
          Icons.more_vert,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildCourseTag() {
    return Container(
      padding: EdgeInsets.all(8),
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle,
            color: SLCColors.navyBlue,
          ),
          SizedBox(width: 8),
          Text("SWE 387", style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: SLCColors.navyBlue.withValues(alpha: 0.3)),
    );
  }

  Widget _buildControlButton() {
    return SLCButton(
      onPressed: _toggleTimer,
      backgroundColor: SLCColors.primaryColor,
      foregroundColor: Colors.white,
      text: _isPlaying ? "Pause" : "Start",
      width: 280,
    );
  }
}
