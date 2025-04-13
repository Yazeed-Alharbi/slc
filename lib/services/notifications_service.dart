import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _notificationsEnabled = false;

  bool get isEnabled => _notificationsEnabled;

  // Channel IDs for different notification types
  static const String _defaultChannelId = 'slc_channel';
  static const String _focusSessionChannelId = 'focus_session_channel';

  /// Initialize the notification service
  Future<void> init() async {
    if (_initialized) return;

    tz_init.initializeTimeZones();

    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Load saved notification preference
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (_notificationsEnabled) {
      // If notifications were enabled before, request permissions again
      final permissionGranted = await requestNotificationPermissions();
      if (!permissionGranted) {
        // If permissions were denied, update the saved preference
        _notificationsEnabled = false;
        await prefs.setBool('notifications_enabled', false);
      }
    }

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification taps here
    // You can navigate to specific screens based on the notification payload
  }

  /// Request notification permissions from the user
  Future<bool> requestNotificationPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Android permissions are assumed to be granted (or handled externally)
    final bool permissionGranted = true;

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final bool? iosPermissionGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return permissionGranted ?? iosPermissionGranted ?? false;
  }

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled == _notificationsEnabled) return;

    if (enabled) {
      final permissionGranted = await requestNotificationPermissions();
      if (!permissionGranted) {
        return; // Don't enable if permissions not granted
      }
    }

    _notificationsEnabled = enabled;

    // Save the setting
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannelId,
          'SLC Notifications',
          channelDescription: 'Notifications for SLC app',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannelId,
          'SLC Notifications',
          channelDescription: 'Notifications for SLC app',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Focus Session Specific Methods

  /// Schedule notification for when a focus session is complete
  Future<void> scheduleSessionCompletionNotification({
    required DateTime scheduledTime,
    required String courseName,
    required int totalPomodoros,
    required String locale,
  }) async {
    if (!_notificationsEnabled) return;

    final title =
        locale == 'ar' ? "تم إكمال جلسة التركيز!" : "Focus Session Complete!";
    final body = locale == 'ar'
        ? "لقد أكملت $totalPomodoros بوموردورو في $courseName"
        : "You completed $totalPomodoros pomodoros in $courseName";

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1, // Use unique ID
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusSessionChannelId,
          'Focus Session Notifications',
          channelDescription: 'Notifications for focus sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule a break time notification
  Future<void> scheduleBreakNotification({
    required DateTime scheduledTime,
    required String breakType,
    required int breakDuration,
    required String locale,
  }) async {
    if (!_notificationsEnabled) return;

    final title = locale == 'ar' ? "وقت الاستراحة!" : "Break Time!";
    final minutes = breakDuration ~/ 60;
    final body = locale == 'ar'
        ? "حان وقت $breakType لمدة $minutes دقائق"
        : "Time for a $breakType for $minutes minutes";

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2, // Use unique ID
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusSessionChannelId,
          'Focus Session Notifications',
          channelDescription: 'Notifications for focus sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule a focus time notification
  Future<void> scheduleFocusTimeNotification({
    required DateTime scheduledTime,
    required String courseName,
    required int pomodoro,
    required int totalPomodoros,
    required String locale,
  }) async {
    if (!_notificationsEnabled) return;

    final title = locale == 'ar' ? "وقت التركيز!" : "Focus Time!";
    final body = locale == 'ar'
        ? "حان وقت البدء في بومودورو $pomodoro من $totalPomodoros لـ $courseName"
        : "Time to start pomodoro $pomodoro of $totalPomodoros for $courseName";

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      3, // Use unique ID
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusSessionChannelId,
          'Focus Session Notifications',
          channelDescription: 'Notifications for focus sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Show a notification for completed pomodoro session
  Future<void> showPomodoroCompletedNotification({
    required String courseName,
    required int totalPomodoros,
    required String locale,
  }) async {
    if (!_notificationsEnabled) return;

    final title =
        locale == 'ar' ? "تم إكمال جلسة التركيز!" : "Focus Session Complete!";
    final body = locale == 'ar'
        ? "لقد أكملت $totalPomodoros بوموردورو في $courseName"
        : "You completed $totalPomodoros pomodoros in $courseName";

    await _flutterLocalNotificationsPlugin.show(
      4, // Use unique ID
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusSessionChannelId,
          'Focus Session Notifications',
          channelDescription: 'Notifications for focus sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Show a break notification
  Future<void> showBreakNotification({
    required String breakType,
    required int breakDuration,
    required String locale,
  }) async {
    if (!_notificationsEnabled) return;

    final title = locale == 'ar' ? "وقت الاستراحة!" : "Break Time!";
    final minutes = breakDuration ~/ 60;
    final body = locale == 'ar'
        ? "حان وقت $breakType لمدة $minutes دقائق"
        : "Time for a $breakType for $minutes minutes";

    await _flutterLocalNotificationsPlugin.show(
      5, // Use unique ID
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusSessionChannelId,
          'Focus Session Notifications',
          channelDescription: 'Notifications for focus sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Show a focus time notification
  Future<void> showFocusTimeNotification({
    required String courseName,
    required int pomodoro,
    required int totalPomodoros,
    required String locale,
  }) async {
    if (!_notificationsEnabled) return;

    final title = locale == 'ar' ? "وقت التركيز!" : "Focus Time!";
    final body = locale == 'ar'
        ? "حان وقت البدء في بومودورو $pomodoro من $totalPomodoros لـ $courseName"
        : "Time to start pomodoro $pomodoro of $totalPomodoros for $courseName";

    await _flutterLocalNotificationsPlugin.show(
      6, // Use unique ID
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusSessionChannelId,
          'Focus Session Notifications',
          channelDescription: 'Notifications for focus sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
