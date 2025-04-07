import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/models/Material.dart';
import 'package:slc/services/notifications_service.dart';

class FocusSessionManager with ChangeNotifier {
  // Singleton instance
  static final FocusSessionManager _instance = FocusSessionManager._internal();
  factory FocusSessionManager() => _instance;
  FocusSessionManager._internal();

  // Add a safeguard for listeners
  final List<Function> _safeListeners = [];
  bool _notifying = false;

  // Session state
  bool _isSessionActive = false;
  bool _isSessionCreated =
      false; // Add a new state variable to distinguish between created and started sessions
  Course? _course;
  CourseEnrollment? _enrollment;
  List<CourseMaterial> _selectedMaterials = [];

  // Timer state
  bool _isPlaying = false;
  String _currentMode = "Focus Time";
  bool _isBreakTime = false;
  int _pomodoroFocusSeconds = 25 * 60; // Default values
  int _shortBreakSeconds = 5 * 60;
  int _longBreakSeconds = 15 * 60;
  int _totalPomodoros = 4;
  int _completedPomodoros = 0;
  bool _sessionCompleted = false;

  // Background tracking
  DateTime? _lastPauseTime;
  DateTime? _sessionStartTime;
  int _elapsedSeconds = 0;
  int _currentDuration = 0;
  Timer? _timer;

  // Create a separate controller for timer updates only
  final StreamController<int> _timerController =
      StreamController<int>.broadcast();
  Stream<int> get timerStream => _timerController.stream;

  // Getters
  bool get isSessionCreated => _isSessionCreated;
  bool get isSessionActive => _isSessionActive; // Remove _isPlaying condition
  Course get course => _course!;
  CourseEnrollment get enrollment => _enrollment!;
  List<CourseMaterial> get selectedMaterials => _selectedMaterials;
  bool get isPlaying => _isPlaying;
  String get currentMode => _currentMode;
  bool get isBreakTime => _isBreakTime;
  int get pomodoroFocusSeconds => _pomodoroFocusSeconds;
  int get shortBreakSeconds => _shortBreakSeconds;
  int get longBreakSeconds => _longBreakSeconds;
  int get totalPomodoros => _totalPomodoros;
  int get completedPomodoros => _completedPomodoros;
  bool get sessionCompleted => _sessionCompleted;
  int get currentDuration => _currentDuration;
  int get elapsedSeconds => _elapsedSeconds;
  bool get hasSession =>
      _isSessionCreated; // Use this for checking if ANY session exists

  // Calculate remaining time
  int get remainingSeconds {
    if (!_isSessionActive) return 0;

    int totalSeconds =
        _isBreakTime ? _shortBreakSeconds : _pomodoroFocusSeconds;
    int remaining = totalSeconds - _elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  // Update the timeRemainingFormatted getter to ensure it always returns the most current value
  String get timeRemainingFormatted {
    // Get the most current remaining seconds for consistency between screens
    int secs = remainingSeconds;
    final minutes = (secs ~/ 60).toString().padLeft(2, '0');
    final seconds = (secs % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Override ChangeNotifier methods for safer listener management
  @override
  void addListener(VoidCallback listener) {
    _safeListeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _safeListeners.remove(listener);
    if (!_notifying) {
      super.removeListener(listener);
    }
  }

  // Override notifyListeners to ensure it's safe and doesn't run during build
  @override
  void notifyListeners() {
    if (_notifying) return;

    // Schedule the notification for the next frame to avoid build-phase conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifying = true;
      // Create a copy to avoid concurrent modification
      final listeners = List.from(_safeListeners);
      for (final listener in listeners) {
        try {
          listener();
        } catch (e) {
          print('Error notifying listener: $e');
          // If a listener throws, we should remove it
          _safeListeners.remove(listener);
        }
      }
      _notifying = false;

      // Only notify active listeners
      super.notifyListeners();
    });
  }

  // Initialize session
  void startSession({
    required Course course,
    required CourseEnrollment enrollment,
    List<CourseMaterial> selectedMaterials = const [],
  }) {
    _course = course;
    _enrollment = enrollment;
    _selectedMaterials = selectedMaterials;
    _isSessionCreated = true; // Mark as created but not active
    _isSessionActive = false; // Only mark as active when timer starts
    _isPlaying = false;
    _currentMode = "Focus Time";
    _isBreakTime = false;
    _completedPomodoros = 0;
    _sessionCompleted = false;
    _elapsedSeconds = 0;
    _currentDuration = _pomodoroFocusSeconds;
    _sessionStartTime = null;
    _lastPauseTime = null;

    _saveSessionState();
    notifyListeners();
  }

  // Update the startTimer method to ensure timer is synchronized
  void startTimer() {
    if (_isPlaying || !_isSessionCreated) return;

    _isPlaying = true;
    _isSessionActive = true;
    _lastPauseTime = null;

    // Record the start time if starting fresh
    if (_sessionStartTime == null) {
      _sessionStartTime = DateTime.now();
    }

    // Calculate the exact start time with second precision to sync timers
    final now = DateTime.now();
    final startSecond = now.second;

    // Start the timer precisely at the next second boundary
    Future.delayed(Duration(milliseconds: 1000 - now.millisecond), () {
      _timer?.cancel();

      // Set up the timer with a clean second boundary
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _elapsedSeconds++;

        // Emit the same value to all listeners at the same time
        _timerController.add(_elapsedSeconds);
        notifyListeners();

        if (_elapsedSeconds >= _currentDuration) {
          _handleTimerCompleted();
        }

        _saveSessionState();
      });

      // Force immediate first update
      notifyListeners();
    });

    // Save state immediately
    _saveSessionState();
    notifyListeners();
  }

  // Restore the improved pause logic with proper order
  void pauseTimer() {
    if (!_isPlaying) return;

    // Cancel timer BEFORE changing state flags
    _timer?.cancel();
    _timer = null;

    // Then update state flags
    _isPlaying = false;
    // Important: Don't set _isSessionActive to false here
    _lastPauseTime = DateTime.now();

    _saveSessionState();
    notifyListeners();
  }

  // End session
  void endSession() {
    _isSessionActive = false;
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    _sessionStartTime = null;
    _lastPauseTime = null;
    _sessionCompleted = false;

    _clearSessionState();
    notifyListeners();
  }

  void _handleTimerCompleted() {
    _timer?.cancel();
    _timer = null;
    _isPlaying = false;

    if (!_isBreakTime) {
      // Transitioning from focus to break
      _completedPomodoros++;

      if (_completedPomodoros >= _totalPomodoros) {
        // Last pomodoro completed: mark session as completed and send quiz notification
        _sessionCompleted = true;

        if (_course != null) {
          NotificationsService().showPomodoroCompletedNotification(
            courseName: _course!.code,
            totalPomodoros: _totalPomodoros,
          );
        }

        _saveSessionState();
        notifyListeners();
        return;
      } else {
        // Not the last pomodoro—switch to break mode and send break notification
        _isBreakTime = true;
        _currentMode = "Short Break";
        _currentDuration = _shortBreakSeconds;

        NotificationsService().showBreakNotification(
          breakType: "Short Break",
          breakDuration: _shortBreakSeconds,
        );
      }
    } else {
      // Transitioning from break to focus
      _isBreakTime = false;
      _currentMode = "Focus Time";
      _currentDuration = _pomodoroFocusSeconds;
    }

    _elapsedSeconds = 0;
    _saveSessionState();
    notifyListeners();
  }

  // Update settings
  void updateSettings({
    required int pomodoro,
    required int shortBreak,
    required int longBreak,
    required int interval,
  }) {
    _pomodoroFocusSeconds = pomodoro * 60;
    _shortBreakSeconds = shortBreak * 60;
    _longBreakSeconds = longBreak * 60;
    _totalPomodoros = interval;

    // Update current duration if needed
    if (!_isBreakTime) {
      _currentDuration = _pomodoroFocusSeconds;
    } else {
      _currentDuration = _shortBreakSeconds;
    }

    _saveSessionState();
    notifyListeners();
  }

  // Update materials
  void updateMaterials(List<CourseMaterial> materials) {
    _selectedMaterials = materials;
    _saveSessionState();
    notifyListeners();
  }

  // Save state to persistence
  Future<void> _saveSessionState() async {
    final prefs = await SharedPreferences.getInstance();

    // Save basic session state
    prefs.setBool('focus_session_active', _isSessionActive);
    if (!_isSessionActive) return;

    // Save session details
    prefs.setString('focus_session_course_id', _course!.id);
    prefs.setString('focus_session_enrollment_id', _enrollment!.id);
    prefs.setBool('focus_session_is_playing', _isPlaying);
    prefs.setString('focus_session_current_mode', _currentMode);
    prefs.setBool('focus_session_is_break', _isBreakTime);
    prefs.setInt('focus_session_completed_pomodoros', _completedPomodoros);
    prefs.setInt('focus_session_pomodoro_seconds', _pomodoroFocusSeconds);
    prefs.setInt('focus_session_short_break_seconds', _shortBreakSeconds);
    prefs.setInt('focus_session_long_break_seconds', _longBreakSeconds);
    prefs.setInt('focus_session_total_pomodoros', _totalPomodoros);
    prefs.setInt('focus_session_elapsed_seconds', _elapsedSeconds);
    prefs.setInt('focus_session_current_duration', _currentDuration);

    // Save course and enrollment data
    prefs.setString('focus_session_course_json', courseToJson(_course!));
    prefs.setString(
        'focus_session_enrollment_json', enrollmentToJson(_enrollment!));

    // Save timestamps
    if (_sessionStartTime != null) {
      prefs.setString(
          'focus_session_start_time', _sessionStartTime!.toIso8601String());
    }
    if (_lastPauseTime != null) {
      prefs.setString(
          'focus_session_pause_time', _lastPauseTime!.toIso8601String());
    }

    // Save selected material IDs
    final materialIds = _selectedMaterials.map((m) => m.id).toList();
    prefs.setStringList('focus_session_materials', materialIds);
  }

  // Clear saved session state
  Future<void> _clearSessionState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('focus_session_active', false);
    // Optional: clear all other keys
    prefs.remove('focus_session_course_id');
    prefs.remove('focus_session_enrollment_id');
    prefs.remove('focus_session_course_json');
    prefs.remove('focus_session_enrollment_json');
    prefs.remove('focus_session_is_playing');
    prefs.remove('focus_session_current_mode');
    prefs.remove('focus_session_is_break');
    prefs.remove('focus_session_completed_pomodoros');
    prefs.remove('focus_session_pomodoro_seconds');
    prefs.remove('focus_session_short_break_seconds');
    prefs.remove('focus_session_long_break_seconds');
    prefs.remove('focus_session_total_pomodoros');
    prefs.remove('focus_session_elapsed_seconds');
    prefs.remove('focus_session_current_duration');
    prefs.remove('focus_session_start_time');
    prefs.remove('focus_session_pause_time');
    prefs.remove('focus_session_materials');
  }

  // Helper functions to serialize/deserialize course and enrollment
  String courseToJson(Course course) {
    // Create a copy of the course's JSON representation
    final Map<String, dynamic> json = course.toJson();

    // Add ID since it's required but not included in toJson
    json['id'] = course.id;

    // Create a recursive function to convert all Timestamp objects
    dynamic convertTimestamps(dynamic value) {
      if (value is Timestamp) {
        return value.toDate().toIso8601String();
      } else if (value is Map) {
        return value
            .map((key, value) => MapEntry(key, convertTimestamps(value)));
      } else if (value is List) {
        return value.map((e) => convertTimestamps(e)).toList();
      }
      return value;
    }

    // Apply the conversion to the entire JSON object
    final convertedJson = convertTimestamps(json);

    return jsonEncode(convertedJson);
  }

  Course courseFromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);

    // Convert created_at string back to Timestamp
    if (json['created_at'] is String) {
      try {
        json['created_at'] =
            Timestamp.fromDate(DateTime.parse(json['created_at']));
      } catch (e) {
        print('Error converting date: $e');
        // Fallback to current time if parsing fails
        json['created_at'] = Timestamp.now();
      }
    }

    return Course.fromJson(json);
  }

  String enrollmentToJson(CourseEnrollment enrollment) {
    return jsonEncode({
      'id': enrollment.id,
      'courseId': enrollment.courseId,
      'completedMaterialIds': enrollment.completedMaterialIds,
      // Add any other fields needed
    });
  }

  CourseEnrollment enrollmentFromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);

    return CourseEnrollment(
      studentId: json['studentId'],
      id: json['id'],
      courseId: json['courseId'],
      completedMaterialIds:
          List<String>.from(json['completedMaterialIds'] ?? []),
    );
  }

  // Restore session from saved state (called at app startup)
  Future<bool> restoreSessionIfActive() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('focus_session_active') ?? false;

    if (!isActive) return false;

    try {
      // Restore course and enrollment objects from serialized data
      final courseJson = prefs.getString('focus_session_course_json');
      final enrollmentJson = prefs.getString('focus_session_enrollment_json');

      if (courseJson == null || enrollmentJson == null) {
        // Missing data, can't restore
        _clearSessionState();
        return false;
      }

      _course = courseFromJson(courseJson);
      _enrollment = enrollmentFromJson(enrollmentJson);

      // Restore session details
      _isSessionActive = true;
      _isPlaying = prefs.getBool('focus_session_is_playing') ?? false;
      _currentMode =
          prefs.getString('focus_session_current_mode') ?? "Focus Time";
      _isBreakTime = prefs.getBool('focus_session_is_break') ?? false;
      _completedPomodoros =
          prefs.getInt('focus_session_completed_pomodoros') ?? 0;
      _pomodoroFocusSeconds =
          prefs.getInt('focus_session_pomodoro_seconds') ?? 25 * 60;
      _shortBreakSeconds =
          prefs.getInt('focus_session_short_break_seconds') ?? 5 * 60;
      _longBreakSeconds =
          prefs.getInt('focus_session_long_break_seconds') ?? 15 * 60;
      _totalPomodoros = prefs.getInt('focus_session_total_pomodoros') ?? 4;
      _currentDuration = prefs.getInt('focus_session_current_duration') ??
          _pomodoroFocusSeconds;
      _elapsedSeconds = prefs.getInt('focus_session_elapsed_seconds') ?? 0;

      // Restore timestamps and calculate elapsed time
      final startTimeStr = prefs.getString('focus_session_start_time');
      final pauseTimeStr = prefs.getString('focus_session_pause_time');

      if (startTimeStr != null) {
        _sessionStartTime = DateTime.parse(startTimeStr);
      }

      if (pauseTimeStr != null) {
        _lastPauseTime = DateTime.parse(pauseTimeStr);
      }

      // Calculate elapsed time if the app was closed while the timer was running
      if (_isPlaying && _sessionStartTime != null) {
        final now = DateTime.now();
        final storedElapsed = _elapsedSeconds;

        // Calculate additional elapsed time since app was closed
        final additionalSeconds =
            now.difference(_sessionStartTime!).inSeconds - storedElapsed;

        if (additionalSeconds > 0) {
          _elapsedSeconds = storedElapsed + additionalSeconds;

          // Check if timer would have completed while app was closed
          if (_elapsedSeconds >= _currentDuration) {
            // Handle timer completion
            _isPlaying = false;
            _handleTimerCompleted();
          }
        }
      }

      // If still playing after restoring, restart the timer
      if (_isPlaying) {
        _timer?.cancel();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          _elapsedSeconds++;

          if (_elapsedSeconds >= _currentDuration) {
            _handleTimerCompleted();
          }

          _saveSessionState();
          notifyListeners();
        });
      }

      notifyListeners();
      return true;
    } catch (e) {
      print("Error restoring session: $e");
      _clearSessionState();
      return false;
    }
  }

  @override
  void dispose() {
    _timerController.close();
    super.dispose();
  }
}
