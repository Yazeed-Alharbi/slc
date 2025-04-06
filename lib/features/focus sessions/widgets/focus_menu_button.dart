import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

class FocusMenuButton extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback? onNotesTap;
  final VoidCallback onAIAssistantTap;

  const FocusMenuButton({
    Key? key,
    required this.onSettingsTap,
    this.onNotesTap,
    required this.onAIAssistantTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () => onNotesTap?.call(),
          title: "Notes",
          icon: Icons.note_alt,
        ),
        PullDownMenuItem(
          onTap: () => onAIAssistantTap(),
          title: "AI Assistant",
          icon: Icons.chat,
        ),
        PullDownMenuItem(
          onTap: () => onSettingsTap(),
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
}
