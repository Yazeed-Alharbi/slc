import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/course%20management/widgets/SLCEventItem.dart';
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
    final themeColor = SLCColors.primaryColor;

    return Padding(
      padding: SpacingStyles(context).defaultPadding,
      child: _isLoading
          ? const Center(child: SLCLoadingIndicator(text: "Loading events..."))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        backgroundColor: SLCColors.primaryColor,
                        foregroundColor: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 35,
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<Event>>(
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
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
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(events.length, (index) {
                          final event = events[index];

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
                              SLCEventItem(
                                themeColor: themeColor,
                                event: event,
                                onEdit: () => _showEditEventDialog(event),
                                onDelete: () => _confirmDeleteEvent(event),
                              ),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
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
    final locationController = TextEditingController(); // Add this line
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Add location field here
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        hintText: "Enter event location (optional)"
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    ListTile(
                      title: const Text("Time"),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          initialEntryMode: TimePickerEntryMode.input,
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
                      SLCFlushbar.show(
                          context: context,
                          message: "Please enter a title",
                          type: FlushbarType.error);
                      return;
                    }

                    Navigator.of(context).pop({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'location': locationController.text, // Add this line
                      'date': selectedDate,
                      'time': selectedTime,
                    });
                  },
                  child: Text("Save",
                      style: TextStyle(
                        color: SLCColors.primaryColor,
                      )),
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
        location: result['location'], // Add this line
        date: result['date'],
        time: result['time'],
      );
    }
  }

  Future<void> _showEditEventDialog(Event event) async {
    final titleController = TextEditingController(text: event.title);
    final descriptionController =
        TextEditingController(text: event.description);
    // Add location controller initialized with event location
    final locationController = TextEditingController(text: event.location ?? "");
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Add location field here
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        hintText: "Enter event location (optional)"
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Existing fields follow
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
                    ListTile(
                      title: const Text("Time"),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          initialEntryMode: TimePickerEntryMode.input,
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
                      'location': locationController.text, // Add this line
                      'date': selectedDate,
                      'time': selectedTime,
                    });
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(color: SLCColors.primaryColor),
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
        location: result['location'], // Add this line
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
    required String location, // Add this line
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      setState(() => _isLoading = true);

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
        location: location, // Add this line
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
    required String location, // Add this line
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      setState(() => _isLoading = true);

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
        location: location, // Add this line
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
