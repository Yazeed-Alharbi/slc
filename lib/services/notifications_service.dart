import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Translations map
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'focusSessionCompleted': 'Focus Session Completed!',
      'pomodoroCompleted':
          'You\'ve completed {count} pomodoros for {course}. Time for a quiz!',
      'breakTime': '{type} Time!',
      'breakDuration': 'Take a break for {minutes} minutes.',
      'breakTimeOver': 'Break Time Over!',
      'focusTimeMessage':
          'Time to focus on {course} (Pomodoro {current} of {total})'
    },
    'ar': {
      'focusSessionCompleted': 'اكتملت جلسة التركيز!',
      'pomodoroCompleted':
          'لقد أكملت {count} من جلسات بومودورو لمقرر {course}. حان وقت الاختبار!',
      'breakTime': 'وقت {type}!',
      'breakDuration': 'خذ استراحة لمدة {minutes} دقائق.',
      'breakTimeOver': 'انتهت وقت الاستراحة!',
      'focusTimeMessage':
          'حان وقت التركيز على {course} (جلسة {current} من {total})'
    }
  };

  // Get translated string based on locale
  String _getTranslation(String key, String locale,
      [Map<String, String>? replacements]) {
    // Debug log to check the selected locale
    print("Getting translation for key: $key, locale: $locale");
    
    // Make sure we use 'ar' or 'en' only
    final validLocale = (locale == 'ar') ? 'ar' : 'en';
    
    // First try to get the translation in the requested locale
    String? text = _translations[validLocale]?[key];
    
    // If not found, fall back to English
    if (text == null) {
      print("Translation not found for $key in $locale, falling back to English");
      text = _translations['en']![key]!;
    }
    
    // Replace placeholders if provided
    if (replacements != null) {
      replacements.forEach((key, value) {
        text = text!.replaceAll('{$key}', value);
      });
    }
    
    return text!;
  }

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
    final ios = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    bool android = true;
    return ios ?? android;
  }

  Future<void> showPomodoroCompletedNotification({
    required String courseName,
    required int totalPomodoros,
    String locale = 'en',
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

    final title = _getTranslation('focusSessionCompleted', locale);
    final message = _getTranslation('pomodoroCompleted', locale,
        {'count': totalPomodoros.toString(), 'course': courseName});

    await _notificationsPlugin.show(
      0,
      title,
      message,
      details,
    );
  }

  Future<void> showBreakNotification({
    required String breakType,
    required int breakDuration,
    String locale = 'en',
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

    final title = _getTranslation('breakTime', locale, {'type': breakType});
    final message = _getTranslation(
        'breakDuration', locale, {'minutes': (breakDuration ~/ 60).toString()});

    await _notificationsPlugin.show(
      1,
      title,
      message,
      details,
    );
  }

  Future<void> scheduleSessionCompletionNotification({
    required DateTime scheduledTime,
    required String courseName,
    required int totalPomodoros,
    String locale = 'en',
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'session_completion_channel',
      'Session Completion Notifications',
      channelDescription: 'Notifies when a focus session is complete',
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

    final title = _getTranslation('focusSessionCompleted', locale);
    final message = _getTranslation('pomodoroCompleted', locale,
        {'count': totalPomodoros.toString(), 'course': courseName});

    await _notificationsPlugin.zonedSchedule(
      0,
      title,
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleBreakNotification({
    required DateTime scheduledTime,
    required String breakType,
    required int breakDuration,
    String locale = 'en',
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

    final title = _getTranslation('breakTime', locale, {'type': breakType});
    final message = _getTranslation(
        'breakDuration', locale, {'minutes': (breakDuration ~/ 60).toString()});

    await _notificationsPlugin.zonedSchedule(
      1,
      title,
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleFocusTimeNotification({
    required DateTime scheduledTime,
    required String courseName,
    required int pomodoro,
    required int totalPomodoros,
    String locale = 'en',
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

    final title = _getTranslation('breakTimeOver', locale);
    final message = _getTranslation('focusTimeMessage', locale, {
      'course': courseName,
      'current': pomodoro.toString(),
      'total': totalPomodoros.toString()
    });

    await _notificationsPlugin.zonedSchedule(
      2,
      title,
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showFocusTimeNotification({
    required String courseName,
    required int pomodoro,
    required int totalPomodoros,
    String locale = 'en',
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

    final title = _getTranslation('breakTimeOver', locale);
    final message = _getTranslation('focusTimeMessage', locale, {
      'course': courseName,
      'current': pomodoro.toString(),
      'total': totalPomodoros.toString()
    });

    await _notificationsPlugin.show(
      2,
      title,
      message,
      details,
    );
  }
}
