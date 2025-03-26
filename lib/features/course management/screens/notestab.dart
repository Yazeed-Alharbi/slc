import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/features/course%20management/widgets/slcnotecard.dart';
import 'package:slc/features/course%20management/screens/note_editor_page.dart';
// Use import prefix for note_service.dart
import 'package:slc/features/course%20management/screens/note_service.dart'
    as service;
// Import Note model separately
import 'package:slc/models/note.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({
    Key? key,
  }) : super(key: key);

  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  // Use the prefix when creating an instance
  final service.NoteService _noteService = service.NoteService();

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    _showCreateNoteDialog(context);
                  },
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

            // StreamBuilder with proper error handling
            StreamBuilder<List<Note>>(
                stream: _noteService.getNotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  if (snapshot.hasError) {
                    print('Error in StreamBuilder: ${snapshot.error}');
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error loading notes: ${snapshot.error}'),
                    ));
                  }

                  final notes = snapshot.data ?? [];
                  print('Notes count in UI: ${notes.length}');

                  if (notes.isEmpty) {
                    return Padding(
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
                    );
                  }

                  return Column(
                    children: notes.map((note) {
                      return Column(
                        children: [
                          SLCNoteCard(
                            title: note.title,
                            createdAt: note.createdAt,
                            onPressed: () async {
                              print('Opening note: ${note.id}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteEditorPage(
                                    noteId: note.id,
                                    noteTitle: note.title,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  );
                }),
          ],
        ),
      ),
    );
  }

  void _showCreateNoteDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Note"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: "Enter note title",
            labelText: "Title",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                try {
                  final noteId = await _noteService.createNote(
                    titleController.text.trim(),
                  );
                  print('Created note with ID: $noteId');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditorPage(
                        noteId: noteId,
                        noteTitle: titleController.text.trim(),
                      ),
                    ),
                  );
                } catch (e) {
                  print('Error creating note: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating note: $e')),
                  );
                }
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
