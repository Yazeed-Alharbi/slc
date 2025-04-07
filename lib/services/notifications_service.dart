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

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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
}
