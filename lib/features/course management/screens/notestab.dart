import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/course%20management/widgets/slcfilecard.dart';
import 'package:slc/features/course%20management/widgets/slcnotecard.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/models/Material.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:path/path.dart' as path;
import 'dart:math';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotesTab extends StatefulWidget {
  const NotesTab({
    Key? key,
  }) : super(key: key);

  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  @override
  Widget build(BuildContext context) {
    // For demo purposes - you'd typically use a state variable to track if notes exist
    bool hasNotes = true; // Change this to false to show empty state

    return SingleChildScrollView(
      child: Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SLCButton(
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  text: "Create note",
                  backgroundColor: SLCColors.primaryColor,
                  foregroundColor: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 35,
                )
              ],
            ),
            const SizedBox(height: 10),

            // If we have notes, show them
            if (hasNotes) ...[
              SLCNoteCard(
                title: "Course Introduction",
                createdAt: DateTime.now(),
                onPressed: () async {
                  // Handle note tap
                  print("Note tapped!");
                },
              ),
              const SizedBox(height: 10),
              SLCNoteCard(
                title: "Week 1 Notes",
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
                onPressed: () async {
                  // Handle note tap
                  print("Note tapped!");
                },
              ),
            ]
            // Otherwise show empty state
            else
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.note_add_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No notes added yet",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create notes using the button above",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
