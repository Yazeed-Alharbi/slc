import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
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
    // Get localized strings
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: SpacingStyles(context).defaultPadding,
      child: _isLoading
          ? Center(
              child: SLCLoadingIndicator(
                  text: l10n?.loadingEvents ?? "Loading events..."))
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
                        text: l10n?.addEvent ?? "Add Event",
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
                        return Center(
                          child: SLCLoadingIndicator(
                              text: l10n?.loadingEvents ?? "Loading events..."),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n?.errorLoadingEvents ??
                                  "Error loading events"),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() {}),
                                child: Text(l10n?.retry ?? "Retry"),
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
                                  l10n?.noEventsScheduled ??
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
                                  l10n?.addEventUsingButton ??
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
                                    _getLocalizedDateHeader(event.dateTime),
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

  // New method to get localized date headers
  String _getLocalizedDateHeader(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (_isSameDay(date, now)) {
      return l10n?.today ?? "Today";
    } else if (_isSameDay(date, tomorrow)) {
      return l10n?.tomorrow ?? "Tomorrow";
    } else if (_isSameDay(date, yesterday)) {
      return l10n?.yesterday ?? "Yesterday";
    } else {
      // Use intl's DateFormat with the current locale
      final locale = Localizations.localeOf(context).languageCode;
      if (date.difference(now).inDays < 7 && date.isAfter(now)) {
        return DateFormat('EEEE', locale)
            .format(date); // e.g. "Monday"/"الاثنين"
      } else {
        return DateFormat('EEEE, MMM d', locale)
            .format(date); // e.g. "Monday, Jan 15"/"الاثنين، يناير ١٥"
      }
    }
  }

  Future<void> _showAddEventDialog() async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n?.addNewEvent ?? "Add New Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n?.title ?? "Title",
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n?.description ?? "Description",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                          labelText: l10n?.location ?? "Location",
                          hintText: l10n?.enterEventLocation ??
                              "Enter event location (optional)"),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(l10n?.date ?? "Date"),
                      subtitle: Text(DateFormat('EEE, MMM d, yyyy',
                              Localizations.localeOf(context).languageCode)
                          .format(selectedDate)),
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
                      title: Text(l10n?.time ?? "Time"),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
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
                    l10n?.cancel ?? "Cancel",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      SLCFlushbar.show(
                        context: context,
                        message: l10n?.titleRequired ?? "Please enter a title",
                        type: FlushbarType.error,
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'location': locationController.text,
                      'date': selectedDate,
                      'time': selectedTime,
                    });
                  },
                  child: Text(l10n?.save ?? "Save",
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
        location: result['location'],
        date: result['date'],
        time: result['time'],
      );
    }
  }

  Future<void> _showEditEventDialog(Event event) async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController(text: event.title);
    final descriptionController =
        TextEditingController(text: event.description);
    final locationController =
        TextEditingController(text: event.location ?? "");
    DateTime selectedDate = event.dateTime;
    TimeOfDay selectedTime =
        TimeOfDay(hour: event.dateTime.hour, minute: event.dateTime.minute);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n?.editEvent ?? "Edit Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n?.title ?? "Title",
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n?.description ?? "Description",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                          labelText: l10n?.location ?? "Location",
                          hintText: l10n?.enterEventLocation ??
                              "Enter event location (optional)"),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(l10n?.date ?? "Date"),
                      subtitle: Text(DateFormat('EEE, MMM d, yyyy',
                              Localizations.localeOf(context).languageCode)
                          .format(selectedDate)),
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
                      title: Text(l10n?.time ?? "Time"),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
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
                    l10n?.cancel ?? "Cancel",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      SLCFlushbar.show(
                        context: context,
                        message: l10n?.titleRequired ?? "Please enter a title",
                        type: FlushbarType.error,
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'location': locationController.text,
                      'date': selectedDate,
                      'time': selectedTime,
                    });
                  },
                  child: Text(
                    l10n?.save ?? "Save",
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
        location: result['location'],
        date: result['date'],
        time: result['time'],
      );
    }
  }

  Future<void> _confirmDeleteEvent(Event event) async {
    final l10n = AppLocalizations.of(context);
    bool confirm = await NativeAlertDialog.show(
      context: context,
      title: l10n?.deleteEvent ?? "Delete Event",
      content: (l10n?.confirmDeleteEvent != null
          ? l10n!.confirmDeleteEvent(event.title)
          : "Are you sure you want to delete '${event.title}'?"),
      confirmText: l10n?.delete ?? "Delete",
      confirmTextColor: Colors.red,
      cancelText: l10n?.cancel ?? "Cancel",
    );

    if (confirm) {
      await _deleteEvent(event.id);
    }
  }

  Future<void> _createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final l10n = AppLocalizations.of(context);
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
        location: location,
        dateTime: dateTime,
        createdBy: widget.enrollment.studentId,
      );

      SLCFlushbar.show(
        context: context,
        message: l10n?.eventCreatedSuccess ?? "Event created successfully",
        type: FlushbarType.success,
      );
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: l10n?.errorCreatingEvent(e.toString()) ??
            "Error creating event: $e",
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
    required String location,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final l10n = AppLocalizations.of(context);
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
        location: location,
        dateTime: dateTime,
      );

      SLCFlushbar.show(
        context: context,
        message: l10n?.eventUpdatedSuccess ?? "Event updated successfully",
        type: FlushbarType.success,
      );
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: l10n?.errorUpdatingEvent(e.toString()) ??
            "Error updating event: $e",
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final l10n = AppLocalizations.of(context);
    try {
      setState(() => _isLoading = true);

      await _eventRepository.deleteEvent(eventId: eventId);

      SLCFlushbar.show(
        context: context,
        message: l10n?.eventDeletedSuccess ?? "Event deleted successfully",
        type: FlushbarType.success,
      );
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: l10n?.errorDeletingEvent(e.toString()) ??
            "Error deleting event: $e",
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
