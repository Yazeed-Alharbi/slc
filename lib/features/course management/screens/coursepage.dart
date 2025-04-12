import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:pull_down_button/pull_down_button.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/course%20management/screens/eventstab.dart';
import 'package:slc/features/course%20management/screens/filestab.dart';
import 'package:slc/features/course%20management/screens/notestab.dart';
import 'package:slc/features/course%20management/widgets/courseform.dart';
import 'package:slc/features/focus%20sessions/screens/focussession.dart';
import 'package:slc/features/focus%20sessions/services/focus_session_manager.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';

class CourseScreen extends StatefulWidget {
  final String courseId;
  final CourseEnrollment enrollment;

  const CourseScreen({
    Key? key,
    required this.courseId,
    required this.enrollment,
  }) : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );
  late TabController _tabController;
  late final Stream<Course?> _courseStream;

  bool _isDeleting = false; // flag

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _courseStream = _courseRepository.streamCourse(widget.courseId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);

    // Localized strings with English fallbacks
    final deletingCourse = l10n?.deletingCourse ?? "Deleting course...";
    final loadingCourse = l10n?.loadingCourse ?? "Loading course...";
    final errorLoadingCourse =
        l10n?.errorLoadingCourse ?? "Error loading course";
    final goBack = l10n?.goBack ?? "Go Back";
    final progressLabel = l10n?.progress ?? "Progress";
    final filesTab = l10n?.files ?? "Files";
    final notesTab = l10n?.notes ?? "Notes";
    final eventsTab = l10n?.events ?? "Events";
    final editLabel = l10n?.editCourse ?? "Edit";
    final deleteLabel = l10n?.deleteCourse ?? "Delete";

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
      child: StreamBuilder<Course?>(
        stream: _courseStream,
        builder: (context, snapshot) {
          if (_isDeleting) {
            return Scaffold(
              body: Center(child: SLCLoadingIndicator(text: deletingCourse)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: SLCLoadingIndicator(text: loadingCourse)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorLoadingCourse),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(goBack),
                    ),
                  ],
                ),
              ),
            );
          }

          final course = snapshot.data!;

          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  color: SLCColors.getCourseColor(course.color),
                  height:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.height * 0.35
                          : MediaQuery.of(context).size.height * 0.55,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -150,
                        top: -150,
                        child: Container(
                          width: 350,
                          height: 350,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(65, 227, 227, 227),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                SpacingStyles(context).defaultPadding.right,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Navigation Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  PullDownButton(
                                    itemBuilder: (context) => [
                                      PullDownMenuItem(
                                        onTap: () => _handleMenuSelection(
                                            'edit', course),
                                        title: editLabel,
                                        icon: Icons.edit,
                                      ),
                                      PullDownMenuItem(
                                        onTap: () => _handleMenuSelection(
                                            'delete', course),
                                        title: deleteLabel,
                                        isDestructive: true,
                                        icon: Icons.delete,
                                      ),
                                    ],
                                    buttonBuilder: (context, showMenu) =>
                                        GestureDetector(
                                      onTap: showMenu,
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    course.code,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 35,
                                      fontWeight: FontWeight.w800,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    course.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SLCButton(
                                onPressed: () => _startFocusSession(
                                    course, widget.enrollment),
                                width: MediaQuery.of(context).size.width * 0.2,
                                text: _getSessionButtonText(course.id, l10n),
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    SLCColors.getCourseColor(course.color),
                                icon: Icon(
                                  _getFocusSessionIcon(course.id),
                                  color: SLCColors.getCourseColor(course.color),
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // Progress indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$progressLabel: ${_calculateProgress(course)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SLCColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _calculateProgress(course) / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            SLCColors.getCourseColor(course.color)),
                      ),
                    ],
                  ),
                ),

                // Tabs Section
                Expanded(
                  child: Column(
                    children: [
                      // TabBar
                      TabBar(
                        controller: _tabController,
                        labelColor: SLCColors.primaryColor,
                        indicatorColor: SLCColors.primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: SLCColors.coolGray,
                        dividerColor: const Color.fromARGB(147, 127, 127, 127),
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        tabs: [
                          Tab(text: filesTab),
                          Tab(text: notesTab),
                          Tab(text: eventsTab),
                        ],
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            FilesTab(
                              course: course,
                              enrollment: widget.enrollment,
                            ),
                            NotesTab(
                              courseId: course.id,
                            ),
                            EventsTab(
                              course: course,
                              enrollment: widget.enrollment,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _startFocusSession(Course course, CourseEnrollment enrollment) async {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final endActiveSessionTitle =
        l10n?.endActiveSessionQuestion ?? "End Active Session?";
    final endSessionConfirmation = l10n?.endSessionConfirmation ??
        "You have an active focus session for ${course.code}. Starting a new session will end the current one. Continue?";
    final endAndStartNew = l10n?.endAndStartNew ?? "End & Start New";
    final cancelText = l10n?.cancel ?? "Cancel";

    // Use a post-frame callback to ensure this happens AFTER the current build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final FocusSessionManager sessionManager = FocusSessionManager();

      // Check if there's already an active session for this course
      if (sessionManager.isSessionActive &&
          sessionManager.course.id == course.id) {
        // Same course session exists, just navigate to it
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FocusSessionScreen(
              course: course,
              enrollment: enrollment,
            ),
          ),
        );
        return;
      }

      // If there's an active session for a different course, show confirmation
      if (sessionManager.isSessionActive) {
        // Ask for confirmation before ending the active session
        final bool shouldEndSession = await NativeAlertDialog.show(
          context: context,
          title: endActiveSessionTitle,
          content: endSessionConfirmation.replaceAll(
              "{courseName}", sessionManager.course.code),
          confirmText: endAndStartNew,
          cancelText: cancelText,
          confirmTextColor: Colors.red,
        );

        if (!shouldEndSession) {
          // User canceled, don't proceed
          return;
        }
      }

      // End any existing session
      sessionManager.endSession();

      // Now navigate to the focus session screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FocusSessionScreen(
            course: course,
            enrollment: enrollment,
          ),
        ),
      );
    });
  }

  void _handleMenuSelection(String value, Course course) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CourseFormScreen(
              course: course,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 200),
            reverseTransitionDuration: const Duration(milliseconds: 200),
          ),
        );
        HapticFeedback.lightImpact();
        break;
      case 'delete':
        _showDeleteConfirmation(course);
        break;
    }
  }

  Future<bool> _showDeleteConfirmation(Course course) async {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final title = l10n?.deleteCourse ?? "Delete Course";
    final content = l10n?.confirmDeleteCourse ??
        "Are you sure you want to delete ${course.name} (${course.code})? This action cannot be undone.";
    final deleteButton = l10n?.delete ?? "Delete";
    final cancelButton = l10n?.cancel ?? "Cancel";

    bool confirmDelete = await NativeAlertDialog.show(
        context: context,
        title: title,
        content: (content as String)
            .replaceAll("{courseName}", "${course.name} (${course.code})"),
        confirmText: deleteButton,
        cancelText: cancelButton,
        confirmTextColor: Colors.red);
    if (confirmDelete) {
      _deleteCourse(course.id);
    }
    return confirmDelete;
  }

  void _deleteCourse(String courseId) async {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final courseDeletedSuccess =
        l10n?.courseDeletedSuccess ?? "Course deleted successfully";
    final failedToDeleteCourse =
        l10n?.failedToDeleteCourse ?? "Failed to delete course";

    try {
      // Set deleting flag to true to bypass StreamBuilder
      setState(() {
        _isDeleting = true;
      });

      // Delete the course
      await _courseRepository.deleteCourse(courseId);

      if (mounted) {
        // Navigate back to course list with a "refresh" result
        Navigator.of(context).pop('refresh');

        // Show success message
        SLCFlushbar.show(
          context: context,
          message: courseDeletedSuccess,
          type: FlushbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        // Reset the deleting flag to show the normal UI again
        setState(() {
          _isDeleting = false;
        });

        // Show error message
        SLCFlushbar.show(
          context: context,
          message: "$failedToDeleteCourse: $e",
          type: FlushbarType.error,
        );
      }
    }
  }

  double _calculateProgress(Course course) {
    if (course.materials.isEmpty) return 0;

    int completedCount = widget.enrollment.completedMaterialIds.length;
    int totalCount = course.materials.length;

    return (completedCount / totalCount * 100).clamp(0, 100);
  }

  String _getSessionButtonText(String courseId, AppLocalizations? l10n) {
    final sessionManager = FocusSessionManager();
    if (sessionManager.isSessionActive &&
        sessionManager.course.id == courseId) {
      return l10n?.goToFocusSession ?? "Go to Focus Session";
    }
    return l10n?.startFocusSession ?? "Start Focus Session";
  }

  IconData _getFocusSessionIcon(String courseId) {
    final sessionManager = FocusSessionManager();
    if (sessionManager.isSessionActive &&
        sessionManager.course.id == courseId) {
      return Icons.arrow_forward;
    }
    return Icons.play_circle;
  }
}
