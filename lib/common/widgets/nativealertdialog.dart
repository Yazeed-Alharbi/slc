import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NativeAlertDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = "OK",
    Color confirmTextColor = Colors.blue,
    VoidCallback? onConfirm,
    String? cancelText, // If null, only confirm button will be shown
    Color cancelTextColor = Colors.grey,
  }) async {
    return await showAdaptiveDialog(
          context: context,
          builder: (BuildContext context) {
            if (Platform.isIOS) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  if (cancelText != null)
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelText,
                          style: TextStyle(color: cancelTextColor)),
                    ),
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      if (onConfirm != null) onConfirm();
                    },
                    isDestructiveAction:
                        confirmTextColor == Colors.red, // For delete actions
                    child: Text(confirmText,
                        style: TextStyle(color: confirmTextColor)),
                  ),
                ],
              );
            } else {
              return AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  if (cancelText != null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            cancelTextColor, 
                      ),
                      child: Text(cancelText),
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      if (onConfirm != null) onConfirm();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: confirmTextColor,
                    ),
                    child: Text(confirmText),
                  ),
                ],
              );
            }
          },
        ) ??
        false;
  }
}
