import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:scribble/scribble.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:flutter/services.dart';
import 'package:slc/features/course%20management/screens/note_service.dart';

class NoteEditorPage extends StatefulWidget {
  final String noteId;
  final String noteTitle;
  final String courseId;

  const NoteEditorPage({
    Key? key,
    required this.noteId,
    required this.noteTitle,
    required this.courseId,
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
  bool _isLoading = true;

  late AnimationController _drawerAnimController;
  late Animation<double> _drawerAnimation;

  late NoteService _noteService;

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

    _noteService = NoteService(courseId: widget.courseId);
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

          // Load the initial sketch if we're in drawing mode
          if (!_isTypingMode && _pages[_currentPageIndex]['sketch'] != null) {
            try {
              final sketchJson = _pages[_currentPageIndex]['sketch'];
              if (sketchJson != null) {
                _scribbleNotifier.setSketch(
                    sketch:
                        Sketch.fromJson(jsonDecode(jsonEncode(sketchJson))));
              }
            } catch (e) {
              // Error restoring initial sketch
            }
          }
        });
      } else {
        _addNewPage(initial: true);
      }
    } catch (e) {
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
        return;
      }

      await _noteService.updateNotePages(widget.noteId, _pages);
    } catch (e) {
      // Error saving to Firestore
    }
  }

  Future<void> _loadPage(int index) async {
    await _saveCurrentPage();
    await _saveToFirestore();

    setState(() {
      _currentPageIndex = index;
      _showPageSelector = false;

      if (_isTypingMode) {
        // Handle text mode
        if (_pages[index]['text'] != null) {
          _textControllers[index].text = _pages[index]['text'].toString();
        }
      } else {
        // Clear the current drawing
        _scribbleNotifier.clear();

        // Load the saved drawing if it exists
        if (_pages[index]['sketch'] != null) {
          try {
            // Convert the stored JSON back to a sketch
            final sketchJson = _pages[index]['sketch'];
            if (sketchJson != null) {
              _scribbleNotifier.setSketch(
                  sketch: Sketch.fromJson(jsonDecode(jsonEncode(sketchJson))));
            }
          } catch (e) {
            // Error restoring sketch
          }
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
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Localized strings with English fallbacks
    final pageText = l10n?.page ?? "Page";
    final pagesText = l10n?.pages ?? "Pages";
    final notesSavedText = l10n?.notesSaved ?? "Note saved!";
    final cannotDeleteOnlyPageText =
        l10n?.cannotDeleteOnlyPage ?? "Cannot delete the only page";
    final deletePageTitle = l10n?.deletePage ?? "Delete Page";
    final confirmDeletePageText = l10n?.confirmDeletePage ??
        "Are you sure you want to delete Page ${_currentPageIndex + 1}?";
    final deleteText = l10n?.delete ?? "Delete";
    final cancelText = l10n?.cancel ?? "Cancel";
    final pageDeletedText = l10n?.pageDeleted ?? "Page deleted";
    final typeNotesHereText = l10n?.typeNotesHere ?? "Type your notes here...";

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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                  '$pageText ${_currentPageIndex + 1}',
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
              tooltip: pagesText,
            ),
            // Text/Draw toggle
            IconButton(
              icon: Icon(_isTypingMode ? Icons.draw : Icons.text_fields),
              onPressed: _toggleInputMode,
              tooltip: _isTypingMode
                  ? l10n?.switchToDrawing ?? 'Switch to Drawing'
                  : l10n?.switchToTyping ?? 'Switch to Typing',
            ),
            // Save button
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _saveCurrentPage();
                await _saveToFirestore();
                SLCFlushbar.show(
                  context: context,
                  message: notesSavedText,
                  type: FlushbarType.success,
                );
              },
              tooltip: l10n?.save ?? 'Save',
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
                          textDirection:
                              isRTL ? TextDirection.rtl : TextDirection.ltr,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                            hintText: typeNotesHereText,
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
                    color: Theme.of(context).colorScheme.surface,
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
                                tooltip: l10n?.addNewPage ?? 'Add new page',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: _deletePage,
                                tooltip: l10n?.deleteCurrentPage ??
                                    'Delete current page',
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

            // Page selector overlay - FIXED for RTL
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
                          // Position the drawer correctly based on text direction
                          Positioned(
                            top: 0,
                            bottom: 0,
                            // Use the appropriate side based on text direction
                            right: isRTL ? 0 : null,
                            left: isRTL ? null : 0,
                            child: AnimatedBuilder(
                              animation: _drawerAnimation,
                              builder: (context, child) {
                                // Calculate position based on animation value and text direction
                                // For RTL: slide from +220 to 0
                                // For LTR: slide from -220 to 0
                                final slidePosition = isRTL
                                    ? 220 * (1 - _drawerAnimation.value)
                                    : -220 * (1 - _drawerAnimation.value);

                                return Transform.translate(
                                  offset: Offset(slidePosition, 0),
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 280,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
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
                                              pagesText,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                _addNewPage();
                                                _togglePageMenu();
                                              },
                                              tooltip: l10n?.addNewPage ??
                                                  'Add new page',
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              child: Material(
                                                color:
                                                    index == _currentPageIndex
                                                        ? Colors.blue
                                                            .withOpacity(0.1)
                                                        : null,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: InkWell(
                                                  onTap: () {
                                                    _loadPage(index);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '$pageText ${index + 1}',
                                                            style: TextStyle(
                                                              fontWeight: index ==
                                                                      _currentPageIndex
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                            ),
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
    final l10n = AppLocalizations.of(context);
    final colorsText = l10n?.colors ?? "Colors";
    final selectColorText = l10n?.selectColor ?? "Select color";

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
          tooltip: selectColorText,
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
                  children: [
                    Text(
                      colorsText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
                  children: colors.map((color) {
                    return InkWell(
                      onTap: () {
                        _scribbleNotifier.setColor(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: currentColor == color
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
    final l10n = AppLocalizations.of(context);
    final cannotDeleteOnlyPageText =
        l10n?.cannotDeleteOnlyPage ?? "Cannot delete the only page";
    final deletePageTitle = l10n?.deletePage ?? "Delete Page";
    final confirmDeletePageText =
        l10n?.confirmDeletePage ?? "Are you sure you want to delete this page?";
    final deleteText = l10n?.delete ?? "Delete";
    final cancelText = l10n?.cancel ?? "Cancel";
    final pageDeletedText = l10n?.pageDeleted ?? "Page deleted";

    // Don't allow deleting if there's only one page
    if (_pages.length <= 1) {
      SLCFlushbar.show(
        context: context,
        message: cannotDeleteOnlyPageText,
        type: FlushbarType.error,
      );
      return;
    }

    // Use NativeAlertDialog.show instead
    NativeAlertDialog.show(
      context: context,
      title: deletePageTitle,
      content: '$confirmDeletePageText ${_currentPageIndex + 1}?',
      confirmText: deleteText,
      confirmTextColor: Colors.red,
      cancelText: cancelText,
    ).then((confirmed) {
      if (confirmed) {
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
              try {
                final sketchJson = _pages[_currentPageIndex]['sketch'];
                if (sketchJson != null) {
                  _scribbleNotifier.setSketch(
                      sketch:
                          Sketch.fromJson(jsonDecode(jsonEncode(sketchJson))));
                }
              } catch (e) {
                // Handle error
              }
            }
          }
        });

        // Save changes to Firestore
        _saveToFirestore();

        SLCFlushbar.show(
          context: context,
          message: pageDeletedText,
          type: FlushbarType.error,
        );
      }
    });
  }
}
