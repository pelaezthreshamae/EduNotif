import 'dart:io' show Platform;           // Only imported when NOT web
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/event.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // 🚫 Web does NOT support notifications → skip everything
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    // 1️⃣ Timezone support
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));

    // 2️⃣ Initialization settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // 3️⃣ Platform-specific permissions
    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImpl?.requestNotificationsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _initialized = true;
  }

  /// Returns the correct notification details based on EventType
  NotificationDetails _buildDetails(EventType type) {
    late AndroidNotificationDetails android;
    late DarwinNotificationDetails ios;

    switch (type) {
      case EventType.exam:
        android = const AndroidNotificationDetails(
          'exam_channel',
          'Exam Reminders',
          channelDescription: 'Reminders for upcoming exams',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('exam'),
        );
        ios = const DarwinNotificationDetails(sound: 'exam.mp3');
        break;

      case EventType.deadline:
        android = const AndroidNotificationDetails(
          'deadline_channel',
          'Deadline Reminders',
          channelDescription: 'Reminders for upcoming deadlines',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('deadline'),
        );
        ios = const DarwinNotificationDetails(sound: 'deadline.mp3');
        break;

      case EventType.activity:
        android = const AndroidNotificationDetails(
          'activity_channel',
          'Activity Reminders',
          channelDescription: 'Activity notifications',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('activity'),
        );
        ios = const DarwinNotificationDetails(sound: 'activity.mp3');
        break;

      case EventType.other:
      default:
        android = const AndroidNotificationDetails(
          'other_channel',
          'General Reminders',
          channelDescription: 'Other types of notifications',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('other'),
        );
        ios = const DarwinNotificationDetails(sound: 'other.mp3');
        break;
    }

    return NotificationDetails(
      android: android,
      iOS: ios,
    );
  }

  int _idFor(String id) => id.hashCode & 0x7fffffff;

  Future<void> scheduleNotification(Event event) async {
    await init();

    // ❌ Do NOT schedule notifications on Web
    if (kIsWeb) return;

    // 1️⃣ If no reminder is set, do nothing
    if (event.reminderBefore == null) return;

    // 2️⃣ Compute trigger time
    final scheduledDate = event.dateTime.subtract(event.reminderBefore!);

    // 3️⃣ Don't schedule if already past
    if (scheduledDate.isBefore(DateTime.now())) return;

    // 4️⃣ Convert to TZ datetime
    final tzTime = tz.TZDateTime.from(scheduledDate, tz.local);

    // 5️⃣ Details
    final details = _buildDetails(event.type);

    // 6️⃣ Schedule
    await _plugin.zonedSchedule(
      _idFor(event.id),
      event.title,
      event.subject ?? event.description ?? 'You have an event coming up',
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelNotification(String eventId) async {
    await init();
    if (kIsWeb) return;
    await _plugin.cancel(_idFor(eventId));
  }

  Future<void> cancelAll() async {
    await init();
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
