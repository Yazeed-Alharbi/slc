import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';

class SLCNoteCard extends StatelessWidget {
  final String title;
  final DateTime createdAt;
  final Future<void> Function() onPressed;
  final Future<void> Function()? onDelete;

  SLCNoteCard({
    Key? key,
    required this.title,
    DateTime? createdAt,
    required this.onPressed,
    this.onDelete,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.yMMMd(locale);
    final createdAtLabel = l10n?.createdAt ?? "Created at:";
    final deleteLabel = l10n?.delete ?? "Delete";
    final confirmDeleteLabel = l10n?.confirmDelete ?? "Confirm Delete";
    final areYouSureDeleteLabel =
        l10n?.areYouSureDelete ?? "Are you sure you want to delete";
    final cancelLabel = l10n?.cancel ?? "Cancel";

    // Base card content
    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/NoteIcon.png",
            width: 35,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "$createdAtLabel ${dateFormat.format(createdAt)}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: SLCColors.coolGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // If onDelete is provided, wrap in Dismissible, otherwise just return the GestureDetector
    if (onDelete == null) {
      return GestureDetector(
        onTap: onPressed,
        child: cardContent,
      );
    }

    // Use Dismissible for swipe-to-delete functionality
    return Dismissible(
      key: Key(title + createdAt.toString()), // Unique key for this note
      direction: DismissDirection.endToStart, // Right to left swipe only
      confirmDismiss: (direction) async {
        // Show confirmation dialog AND RETURN ITS RESULT
        return await NativeAlertDialog.show(
          context: context,
          title: confirmDeleteLabel,
          content: "$areYouSureDeleteLabel \"$title\"?",
          confirmText: deleteLabel,
          confirmTextColor: Colors.red,
          cancelText: cancelLabel,
        );
      },
      onDismissed: (direction) {
        // Execute the delete function
        onDelete!();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: cardContent,
      ),
    );
  }
}
