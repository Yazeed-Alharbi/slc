import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:flutter/services.dart';
import 'package:slc/features/course%20management/screens/note_service.dart';

class NoteEditorPage extends StatefulWidget {
  final String noteId;
  final String noteTitle;
  final String courseId; // Add courseId parameter

  const NoteEditorPage({
    Key? key,
    required this.noteId,
    required this.noteTitle,
    required this.courseId, // Add this parameter
  }) : super(key: key);

  @override
  _NoteEditorPageState createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage>
    with SingleTickerProviderStateMixin {
  late ScribbleNotifier _scribbleNotifier;
  final List<TextEditingController> _textControllers = [];
  final List<Map<String, dynamic>> _pages = [];
  int _currentPageIndex = 0;
  bool _isTypingMode = false;
  bool _showPageSelector = false;
  bool _isLoading = true; // Add loading state

  late AnimationController _drawerAnimController;
  late Animation<double> _drawerAnimation;

  late NoteService _noteService; // Update initialization of NoteService

  @override
  void initState() {
    super.initState();
    _scribbleNotifier = ScribbleNotifier();

    // Initialize animation controller
    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Create animation
    _drawerAnimation = CurvedAnimation(
      parent: _drawerAnimController,
      curve: Curves.easeInOut,
    );

    _noteService = NoteService(
        courseId: widget.courseId); // Initialize NoteService with courseId

    // Load note data from Firestore instead of adding first page directly
    _loadNoteData();
  }

  // New method to load note data from Firestore
  Future<void> _loadNoteData() async {
    try {
      final note = await _noteService.getNote(widget.noteId);

      if (note != null && note.pages.isNotEmpty) {
        setState(() {
          _pages.clear();
          _textControllers.clear();

          // Add all pages from Firestore
          for (var page in note.pages) {
            _pages.add(page);
            _textControllers.add(TextEditingController(
              text: page['text']?.toString() ?? '',
            ));
          }
        });
      } else {
        // If the note doesn't exist or has no pages, add a default page
        _addNewPage(initial: true);
      }
    } catch (e) {
      print('Error loading note: $e');
      // Add a default page in case of error
      _addNewPage(initial: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scribbleNotifier.dispose();
    _drawerAnimController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewPage({bool initial = false}) {
    if (!initial) {
      // Save current page first
      _saveCurrentPage();
    }

    setState(() {
      _pages.add({
        'sketch': null, // Will store JSON of sketch
        'text': '',
      });
      _textControllers.add(TextEditingController(text: ''));

      if (!initial) {
        _currentPageIndex = _pages.length - 1;
        _scribbleNotifier.clear();
      }
    });

    // Save to Firestore if not initial load
    if (!initial) {
      _saveToFirestore();
    }
  }

  Future<void> _saveCurrentPage() async {
    if (_pages.isEmpty || _currentPageIndex >= _pages.length) {
      return;
    }

    if (!_isTypingMode) {
      // Save drawing
      final json = _scribbleNotifier.currentSketch.toJson();
      _pages[_currentPageIndex]['sketch'] = json;
    } else {
      // Save text - make sure it's a string
      _pages[_currentPageIndex]['text'] =
          _textControllers[_currentPageIndex].text;
    }
  }

  Future<void> _saveToFirestore() async {
    try {
      if (_pages.isEmpty) {
        // Don't save if there are no pages
        return;
      }

      await _noteService.updateNotePages(widget.noteId, _pages);
    } catch (e) {
      print('Error saving to Firestore: $e');
      // Don't show an error message here to avoid disrupting the user experience
      // We'll just log it and continue
    }
  }

  Future<void> _loadPage(int index) async {
    await _saveCurrentPage();
    await _saveToFirestore(); // Add Firestore save

    setState(() {
      _currentPageIndex = index;
      _showPageSelector = false;

      if (_isTypingMode) {
        // No need to do anything special for text mode
        // Make sure text controller has the right value
        if (_pages[index]['text'] != null) {
          _textControllers[index].text = _pages[index]['text'].toString();
        }
      } else {
        // Clear the current drawing
        _scribbleNotifier.clear();

        // Load the saved drawing if it exists
        if (_pages[index]['sketch'] != null) {
          // We'd restore the sketch here from json
          // Not directly supported by the library but could be implemented
        }
      }
    });
  }

  void _toggleInputMode() async {
    await _saveCurrentPage();
    await _saveToFirestore(); // Add Firestore save

    setState(() {
      _isTypingMode = !_isTypingMode;
    });
  }

  void _togglePageSelector() {
    setState(() {
      _showPageSelector = !_showPageSelector;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add loading indicator
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.noteTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_showPageSelector) {
          _togglePageMenu();
          return false;
        }
        await _saveCurrentPage();
        await _saveToFirestore(); // Add Firestore save
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.noteTitle),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          // Back button in the standard leading position
          // In the leading back button in build method:
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _saveCurrentPage();
              try {
                await _saveToFirestore();
              } catch (e) {
                print('Error saving before navigation: $e');
              }
              if (mounted) {
                // Add this check
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            // Page indicator
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Page ${_currentPageIndex + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Menu button
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: _togglePageMenu,
              tooltip: 'Pages menu',
            ),
            // Text/Draw toggle
            IconButton(
              icon: Icon(_isTypingMode ? Icons.draw : Icons.text_fields),
              onPressed: _toggleInputMode,
              tooltip: _isTypingMode ? 'Switch to Drawing' : 'Switch to Typing',
            ),
            // Save button
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _saveCurrentPage();
                await _saveToFirestore(); // Add Firestore save
                SLCFlushbar.show(
                  context: context,
                  message: "Note saved!",
                  type: FlushbarType.success,
                );
              },
              tooltip: 'Save',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main content area
            Column(
              children: [
                // Drawing/Text Area
                Expanded(
                  child: _isTypingMode
                      ? TextField(
                          controller: _textControllers[_currentPageIndex],
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                            hintText: 'Type your notes here...',
                          ),
                        )
                      : Container(
                          color: Colors.white,
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            boundaryMargin:
                                const EdgeInsets.all(double.infinity),
                            child: ClipRect(
                              child: Scribble(
                                notifier: _scribbleNotifier,
                                drawPen: true,
                              ),
                            ),
                          ),
                        ),
                ),

                // Drawing tools toolbar - Only shown in drawing mode
                if (!_isTypingMode)
                  Material(
                    elevation: 4,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Color selector
                          _buildColorSelector(),
                          const SizedBox(width: 16),
                          // Eraser
                          ValueListenableBuilder(
                            valueListenable: _scribbleNotifier,
                            builder: (context, value, child) => IconButton(
                              icon: const Icon(Icons.cleaning_services),
                              style: IconButton.styleFrom(
                                backgroundColor: value is Erasing
                                    ? SLCColors.primaryColor
                                    : Colors.grey[200],
                                foregroundColor: value is Erasing
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () => _scribbleNotifier.setEraser(),
                            ),
                          ),
                          const Spacer(),
                          // Page management buttons grouped together
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: _addNewPage,
                                tooltip: 'Add new page',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: _deletePage,
                                tooltip: 'Delete current page',
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Undo/Redo
                          ValueListenableBuilder(
                            valueListenable: _scribbleNotifier,
                            builder: (context, value, child) => IconButton(
                              icon: const Icon(Icons.undo),
                              onPressed: _scribbleNotifier.canUndo
                                  ? _scribbleNotifier.undo
                                  : null,
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _scribbleNotifier,
                            builder: (context, value, child) => IconButton(
                              icon: const Icon(Icons.redo),
                              onPressed: _scribbleNotifier.canRedo
                                  ? _scribbleNotifier.redo
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Page selector overlay
            if (_showPageSelector)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: _togglePageMenu,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Stack(
                        children: [
                          // Side panel for pages - positioned with proper padding
                          AnimatedBuilder(
                            animation: _drawerAnimation,
                            builder: (context, child) {
                              // Calculate position based on animation value
                              // -220 (fully off-screen) to 0 (fully visible)
                              final slidePosition =
                                  -220 * (1 - _drawerAnimation.value);

                              return Transform.translate(
                                offset: Offset(slidePosition, 0),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 280,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: SafeArea(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Pages',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              _togglePageMenu();
                                              _addNewPage();
                                            },
                                            tooltip: 'Add new page',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.only(
                                            top: 8, bottom: 8),
                                        itemCount: _pages.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            child: Material(
                                              color: index == _currentPageIndex
                                                  ? SLCColors.primaryColor
                                                      .withOpacity(0.15)
                                                  : Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                onTap: () {
                                                  _loadPage(index);
                                                  _togglePageMenu();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 36,
                                                        height: 36,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: index ==
                                                                  _currentPageIndex
                                                              ? SLCColors
                                                                  .primaryColor
                                                              : Theme.of(context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors
                                                                      .grey[200]
                                                                  : Colors.grey[
                                                                      800],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${index + 1}',
                                                            style: TextStyle(
                                                              color: index ==
                                                                      _currentPageIndex
                                                                  ? Colors.white
                                                                  : Theme.of(context)
                                                                              .brightness ==
                                                                          Brightness
                                                                              .light
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Page ${index + 1}',
                                                              style: TextStyle(
                                                                fontWeight: index ==
                                                                        _currentPageIndex
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            if (_pages[index]
                                                                        ['text']
                                                                    ?.isNotEmpty ??
                                                                false)
                                                              Text(
                                                                _pages[index]['text']
                                                                            .toString()
                                                                            .length >
                                                                        20
                                                                    ? _pages[index]['text']
                                                                            .toString()
                                                                            .substring(0,
                                                                                20) +
                                                                        "..."
                                                                    : _pages[index]
                                                                            [
                                                                            'text']
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Add this method to toggle the drawer
  void _toggleDrawer() {
    setState(() {
      _showPageSelector = !_showPageSelector;
    });
  }

  // Replace _buildColorButton with this dropdown color selector
  Widget _buildColorSelector() {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    return ValueListenableBuilder(
      valueListenable: _scribbleNotifier,
      builder: (context, value, child) {
        // Get the currently selected color or default to black
        Color currentColor = Colors.black;
        if (value is Drawing) {
          currentColor = Color(value.selectedColor);
        }

        return PopupMenuButton<Color>(
          tooltip: 'Select color',
          offset: const Offset(0, 45),
          onSelected: (Color color) {
            _scribbleNotifier.setColor(color);
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                enabled: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Text('Select Color',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors
                      .map((color) => GestureDetector(
                            onTap: () {
                              _scribbleNotifier.setColor(color);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color == currentColor
                                      ? Colors.white
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                boxShadow: color == currentColor
                                    ? [
                                        BoxShadow(
                                            color: color.withOpacity(0.4),
                                            blurRadius: 4)
                                      ]
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ];
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentColor,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)
              ],
            ),
            child: const Icon(Icons.arrow_drop_down, color: Colors.white),
          ),
        );
      },
    );
  }

  // Rename the method for clarity
  void _togglePageMenu() {
    if (_showPageSelector) {
      // Close menu
      _drawerAnimController.reverse().then((_) {
        setState(() {
          _showPageSelector = false;
        });
      });
    } else {
      // Open menu
      setState(() {
        _showPageSelector = true;
      });
      _drawerAnimController.forward();
    }
  }

  // First, add this method to handle page deletion
  void _deletePage() {
    // Don't allow deleting if there's only one page
    if (_pages.length <= 1) {
      SLCFlushbar.show(
        context: context,
        message: "Cannot delete the only page",
        type: FlushbarType.error,
      );
      return;
    }

    // Use NativeAlertDialog.show instead
    NativeAlertDialog.show(
      context: context,
      title: 'Delete Page',
      content: 'Are you sure you want to delete Page ${_currentPageIndex + 1}?',
      confirmText: "Delete",
      confirmTextColor: Colors.red,
      cancelText: "Cancel",
      onConfirm: () async {
        setState(() {
          // Remove the page data
          _pages.removeAt(_currentPageIndex);

          // Dispose the text controller
          _textControllers[_currentPageIndex].dispose();
          _textControllers.removeAt(_currentPageIndex);

          // Update the current page index
          if (_currentPageIndex >= _pages.length) {
            _currentPageIndex = _pages.length - 1;
          }

          // Load the new current page
          if (!_isTypingMode) {
            _scribbleNotifier.clear();

            // Load the saved drawing if it exists
            if (_pages[_currentPageIndex]['sketch'] != null) {
              // Would restore the sketch here
            }
          }
        });

        // Save changes to Firestore
        _saveToFirestore();

        SLCFlushbar.show(
          context: context,
          message: "Page deleted",
          type: FlushbarType.error,
        );
      },
    );
  }
}
