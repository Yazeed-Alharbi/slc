import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Define app icon as notification icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );

    _initialized = true;
  }

  Future<bool> requestNotificationPermissions() async {
    // Request iOS permissions
    final ios = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For Android, permissions are managed differently.
    // Since the method requestPermission() is not available,
    // you may simply assume permissions are granted for older versions.
    // Alternatively, use a package like permission_handler for Android 13+.
    bool android = true;

    return ios ?? android;
  }

  Future<void> showPomodoroCompletedNotification({
    required String courseName,
    required int totalPomodoros,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'focus_session_channel',
      'Focus Session Notifications',
      channelDescription: 'Notifies when focus sessions are completed',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Focus session completed',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Focus Session Completed!',
      'You\'ve completed $totalPomodoros pomodoros for $courseName. Time for a quiz!',
      details,
    );
  }

  Future<void> showBreakNotification({
    required String breakType, // e.g., "Short Break" or "Long Break"
    required int breakDuration, // in seconds
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'break_channel',
      'Break Notifications',
      channelDescription: 'Notifies when it is time for a break',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Break Time!',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1, // Use a unique ID for break notifications
      '$breakType Time!',
      'Take a break for ${breakDuration ~/ 60} minutes.',
      details,
    );
  }

  Future<void> scheduleSessionCompletionNotification({
    required DateTime scheduledTime,
    required String courseName,
    required int totalPomodoros,
  }) async {
    await initialize();

    // Use exactScheduleMode to ensure precise timing, even when app is backgrounded
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'session_completion_channel',
      'Session Completion Notifications',
      channelDescription: 'Notifies when a focus session is complete',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true, // Will pop up even if device is locked
      category: AndroidNotificationCategory
          .alarm, // Uses the alarm category for higher priority
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel:
          InterruptionLevel.timeSensitive, // Higher priority on iOS
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for exact time, allowing it to wake device if needed
    await _notificationsPlugin.zonedSchedule(
      0,
      'Focus Session Completed',
      'You\'ve completed $totalPomodoros pomodoros for $courseName. Time for a quiz!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Add this method for break notifications
  Future<void> scheduleBreakNotification({
    required DateTime scheduledTime,
    required String breakType,
    required int breakDuration,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'break_channel',
      'Break Notifications',
      channelDescription: 'Notifies when it is time for a break',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      1, // Use a different ID for break notifications
      'Time for a $breakType!',
      'Take a break for ${breakDuration ~/ 60} minutes.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Add this method for resume focus notifications
  Future<void> scheduleFocusTimeNotification({
    required DateTime scheduledTime,
    required String courseName,
    required int pomodoro,
    required int totalPomodoros,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'focus_channel',
      'Focus Time Notifications',
      channelDescription: 'Notifies when it is time to focus again',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      2, // Use a different ID for focus notifications
      'Break time over!',
      'Time to focus on $courseName (Pomodoro $pomodoro of $totalPomodoros)',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Add this method to NotificationsService class
  Future<void> showFocusTimeNotification({
    required String courseName,
    required int pomodoro,
    required int totalPomodoros,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'focus_channel',
      'Focus Time Notifications',
      channelDescription: 'Notifies when it is time to focus again',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      2, // Use a different ID for focus notifications
      'Break Time Over!',
      'Time to focus on $courseName (Pomodoro $pomodoro of $totalPomodoros)',
      details,
    );
  }
}
