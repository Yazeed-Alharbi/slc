import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () => onNotesTap?.call(),
          title: l10n?.notes ?? "Notes",
          icon: Icons.note_alt,
        ),
        PullDownMenuItem(
          onTap: () => onAIAssistantTap(),
          title: l10n?.aiAssistant ?? "AI Assistant",
          icon: Icons.chat,
        ),
        PullDownMenuItem(
          onTap: () => onSettingsTap(),
          title: l10n?.settings ?? "Settings",
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
