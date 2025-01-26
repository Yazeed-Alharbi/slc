import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

enum FlushbarType { success, error, warning }

class SLCFlushbar {
  static void show({
    required BuildContext context,
    required String message,
    required FlushbarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;

    switch (type) {
      case FlushbarType.success:
        backgroundColor = Colors.green;
        break;
      case FlushbarType.error:
        backgroundColor = Colors.red;
        break;
      case FlushbarType.warning:
        backgroundColor = Colors.orange;
        break;
    }

    // Show the Flushbar
    Flushbar(
      flushbarStyle: FlushbarStyle.GROUNDED,
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      message: message,
      duration: duration,
      animationDuration: const Duration(milliseconds: 250),
    ).show(context);
  }
}
