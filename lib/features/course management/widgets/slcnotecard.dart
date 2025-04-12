import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import

class SLCNoteCard extends StatelessWidget {
  final String title;
  final DateTime createdAt;
  final Future<void> Function() onPressed;

  SLCNoteCard({
    Key? key,
    required this.title,
    DateTime? createdAt,
    required this.onPressed,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);

    // Get the appropriate date formatter based on current locale
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.yMMMd(locale);

    // Translated "Created at:" with English fallback
    final createdAtLabel = l10n?.createdAt ?? "Created at:";

    return GestureDetector(
      onTap: onPressed, // Connect the onPressed callback here
      child: Container(
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
            const SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, // Dynamic file name
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
          ],
        ),
      ),
    );
  }
}
