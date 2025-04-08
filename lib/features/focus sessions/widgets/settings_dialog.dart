import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';

class SettingsDialog extends StatefulWidget {
  final int pomodoroMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;
  final Function(int, int, int, int) onSave;

  const SettingsDialog({
    Key? key,
    required this.pomodoroMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.longBreakInterval,
    required this.onSave,
  }) : super(key: key);

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _pomodoroController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    _pomodoroController =
        TextEditingController(text: widget.pomodoroMinutes.toString());
    _shortBreakController =
        TextEditingController(text: widget.shortBreakMinutes.toString());
    _longBreakController =
        TextEditingController(text: widget.longBreakMinutes.toString());
    _intervalController =
        TextEditingController(text: widget.longBreakInterval.toString());
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timer Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Pomodoro Duration
            SLCTextField(
              controller: _pomodoroController,
              labelText: 'Pomodoro (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Short Break Duration
            SLCTextField(
              controller: _shortBreakController,
              labelText: 'Short Break (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Long Break Duration
            SLCTextField(
              controller: _longBreakController,
              labelText: 'Long Break (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Long Break Interval
            SLCTextField(
              controller: _intervalController,
              labelText: 'Number of pomodoros',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SLCButton(
                  width: 60,
                  backgroundColor: Colors.transparent,
                  foregroundColor: SLCColors.primaryColor,
                  onPressed: () => Navigator.of(context).pop(),
                  text: "CANCEL",
                ),
                const SizedBox(width: 16),
                SLCButton(
                  width: 60,
                  text: "SAVE",
                  foregroundColor: Colors.white,
                  backgroundColor: SLCColors.primaryColor,
                  onPressed: () {
                    // Parse values
                    final pomodoro = int.tryParse(_pomodoroController.text) ??
                        widget.pomodoroMinutes;
                    final shortBreak =
                        int.tryParse(_shortBreakController.text) ??
                            widget.shortBreakMinutes;
                    final longBreak = int.tryParse(_longBreakController.text) ??
                        widget.longBreakMinutes;
                    final interval = int.tryParse(_intervalController.text) ??
                        widget.longBreakInterval;

                    // Call callback with new values
                    widget.onSave(pomodoro, shortBreak, longBreak, interval);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
