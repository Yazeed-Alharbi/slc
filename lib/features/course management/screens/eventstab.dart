import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/models/event.dart';
import 'package:slc/repositories/event_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:intl/intl.dart';

class EventsTab extends StatefulWidget {
  final Course course;
  final CourseEnrollment enrollment;

  const EventsTab({
    Key? key,
    required this.course,
    required this.enrollment,
  }) : super(key: key);

  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final EventRepository _eventRepository = EventRepository(
    firestoreUtils: FirestoreUtils(),
  );

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = SLCColors.getCourseColor(widget.course.color);

    return Padding(
      padding: SpacingStyles(context).defaultPadding,
      child: Column(
        children: [
          // Add button row at the top
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SLCButton(
                width: MediaQuery.sizeOf(context).width * 0.3,
                onPressed: _showAddEventDialog,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                text: "Add Event",
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 40,
              )
            ],
          ),
          const SizedBox(height: 16),

          // Main content area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: SLCLoadingIndicator(text: "Loading events..."))
                : StreamBuilder<List<Event>>(
                    stream:
                        _eventRepository.streamCourseEvents(widget.course.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                SLCLoadingIndicator(text: "Loading events..."));
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Error loading events"),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() {}),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      }

                      final events = snapshot.data ?? [];

                      if (events.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No events scheduled",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Add a new event using the button above",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SLCButton(
                                onPressed: _showAddEventDialog,
                                text: "Add Your First Event",
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                width: 200,
                                height: 46,
                                fontSize: 16,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];

                          // Show date header if first event or different day
                          bool showDateHeader = index == 0 ||
                              !_isSameDay(
                                  events[index - 1].dateTime, event.dateTime);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDateHeader) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12.0, bottom: 8.0),
                                  child: Text(
                                    _formatDateHeader(event.dateTime),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],

                              // Event card
                              Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    // Time header with course color
                                    Container(
                                      decoration: BoxDecoration(
                                        color: themeColor.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: themeColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateFormat('h:mm a')
                                                .format(event.dateTime),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: themeColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: Icon(Icons.edit_outlined,
                                                color: themeColor),
                                            onPressed: () =>
                                                _showEditEventDialog(event),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _confirmDeleteEvent(event),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Event content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (event.description.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              event.description,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: SLCLoadingIndicator(text: "Processing..."),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (_isSameDay(date, now)) {
      return "Today";
    } else if (_isSameDay(date, tomorrow)) {
      return "Tomorrow";
    } else if (_isSameDay(date, yesterday)) {
      return "Yesterday";
    } else if (date.difference(now).inDays < 7 && date.isAfter(now)) {
      return DateFormat('EEEE').format(date); // e.g. "Monday"
    } else {
      return DateFormat('EEEE, MMM d').format(date); // e.g. "Monday, Jan 15"
    }
  }

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        hintText: "Event title",
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        hintText: "Event description",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Date picker
                    ListTile(
                      title: const Text("Date"),
                      subtitle: Text(
                          DateFormat('EEE, MMM d, yyyy').format(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),

                    // Time picker
                    ListTile(
                      title: const Text("Time"),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          initialEntryMode: TimePickerEntryMode
                              .input, // Change this line to force keyboard input
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  dialHandColor: SLCColors.getCourseColor(
                                      widget.course.color),
                                  hourMinuteTextColor:
                                      MaterialStateColor.resolveWith((states) =>
                                          states.contains(
                                                  MaterialState.selected)
                                              ? SLCColors.getCourseColor(
                                                  widget.course.color)
                                              : Colors.black),
                                  dayPeriodTextColor:
                                      MaterialStateColor.resolveWith((states) =>
                                          states.contains(
                                                  MaterialState.selected)
                                              ? SLCColors.getCourseColor(
                                                  widget.course.color)
                                              : Colors.black),
                                ),
                                colorScheme: ColorScheme.light(
                                  primary: SLCColors.getCourseColor(
                                      widget.course.color),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a title")),
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'date': selectedDate,
                      'time': selectedTime,
                    });
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: SLCColors.getCourseColor(widget.course.color)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await _createEvent(
        title: result['title'],
        description: result['description'],
        date: result['date'],
        time: result['time'],
      );
    }
  }

  Future<void> _showEditEventDialog(Event event) async {
    final titleController = TextEditingController(text: event.title);
    final descriptionController =
        TextEditingController(text: event.description);
    DateTime selectedDate = event.dateTime;
    TimeOfDay selectedTime =
        TimeOfDay(hour: event.dateTime.hour, minute: event.dateTime.minute);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        hintText: "Event title",
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        hintText: "Event description",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Date picker
                    ListTile(
                      title: const Text("Date"),
                      subtitle: Text(
                          DateFormat('EEE, MMM d, yyyy').format(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),

                    // Time picker
                    ListTile(
                      title: const Text("Time"),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          initialEntryMode: TimePickerEntryMode
                              .input, // Change this line to force keyboard input
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  dialHandColor: SLCColors.getCourseColor(
                                      widget.course.color),
                                  hourMinuteTextColor:
                                      MaterialStateColor.resolveWith((states) =>
                                          states.contains(
                                                  MaterialState.selected)
                                              ? SLCColors.getCourseColor(
                                                  widget.course.color)
                                              : Colors.black),
                                  dayPeriodTextColor:
                                      MaterialStateColor.resolveWith((states) =>
                                          states.contains(
                                                  MaterialState.selected)
                                              ? SLCColors.getCourseColor(
                                                  widget.course.color)
                                              : Colors.black),
                                ),
                                colorScheme: ColorScheme.light(
                                  primary: SLCColors.getCourseColor(
                                      widget.course.color),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a title")),
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'date': selectedDate,
                      'time': selectedTime,
                    });
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: SLCColors.getCourseColor(widget.course.color)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await _updateEvent(
        eventId: event.id,
        title: result['title'],
        description: result['description'],
        date: result['date'],
        time: result['time'],
      );
    }
  }

  Future<void> _confirmDeleteEvent(Event event) async {
    bool confirm = await NativeAlertDialog.show(
      context: context,
      title: "Delete Event",
      content: "Are you sure you want to delete '${event.title}'?",
      confirmText: "Delete",
      confirmTextColor: Colors.red,
      cancelText: "Cancel",
    );

    if (confirm) {
      await _deleteEvent(event.id);
    }
  }

  Future<void> _createEvent({
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      setState(() => _isLoading = true);

      // Combine date and time
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      await _eventRepository.createEvent(
        courseId: widget.course.id,
        title: title,
        description: description,
        dateTime: dateTime,
        createdBy: widget.enrollment.studentId,
      );

      SLCFlushbar.show(
        context: context,
        message: "Event created successfully",
        type: FlushbarType.success,
      );
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Error creating event: $e",
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      setState(() => _isLoading = true);

      // Combine date and time
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      await _eventRepository.updateEvent(
        eventId: eventId,
        title: title,
        description: description,
        dateTime: dateTime,
      );

      SLCFlushbar.show(
        context: context,
        message: "Event updated successfully",
        type: FlushbarType.success,
      );
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Error updating event: $e",
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      setState(() => _isLoading = true);

      await _eventRepository.deleteEvent(eventId: eventId);

      SLCFlushbar.show(
        context: context,
        message: "Event deleted successfully",
        type: FlushbarType.success,
      );
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Error deleting event: $e",
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
