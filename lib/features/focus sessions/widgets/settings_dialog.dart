import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';

class SettingsDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Create TextEditingControllers with initial values
    final pomodoroController =
        TextEditingController(text: pomodoroMinutes.toString());
    final shortBreakController =
        TextEditingController(text: shortBreakMinutes.toString());
    final longBreakController =
        TextEditingController(text: longBreakMinutes.toString());
    final longBreakIntervalController =
        TextEditingController(text: longBreakInterval.toString());

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
              controller: pomodoroController,
              labelText: 'Pomodoro (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Short Break Duration
            SLCTextField(
              controller: shortBreakController,
              labelText: 'Short Break (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Long Break Duration
            SLCTextField(
              controller: longBreakController,
              labelText: 'Long Break (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Long Break Interval
            SLCTextField(
              controller: longBreakIntervalController,
              labelText: 'Long Break Interval (pomodoros)',
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
                    final pomodoro = int.tryParse(pomodoroController.text) ??
                        pomodoroMinutes;
                    final shortBreak =
                        int.tryParse(shortBreakController.text) ??
                            shortBreakMinutes;
                    final longBreak = int.tryParse(longBreakController.text) ??
                        longBreakMinutes;
                    final interval =
                        int.tryParse(longBreakIntervalController.text) ??
                            longBreakInterval;

                    // Call callback with new values
                    onSave(pomodoro, shortBreak, longBreak, interval);

                    Navigator.of(context).pop();
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
