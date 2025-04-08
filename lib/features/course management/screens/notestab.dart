import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/features/course%20management/widgets/slcnotecard.dart';
import 'package:slc/features/course%20management/screens/note_editor_page.dart';
import 'package:slc/features/course%20management/screens/note_service.dart'
    as service;
import 'package:slc/models/note.dart';
// Add or use your course provider

class NotesTab extends StatefulWidget {
  final String courseId;

  const NotesTab({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  late service.NoteService _noteService;

  @override
  void initState() {
    super.initState();
    _noteService = service.NoteService(courseId: widget.courseId);
  }

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
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error loading notes: ${snapshot.error}'),
                    ));
                  }

                  final notes = snapshot.data ?? [];

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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteEditorPage(
                                    noteId: note.id,
                                    noteTitle: note.title,
                                    courseId: widget.courseId,
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditorPage(
                        noteId: noteId,
                        noteTitle: titleController.text.trim(),
                        courseId: widget.courseId,
                      ),
                    ),
                  );
                } catch (e) {
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
