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

    // Timezone support
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila')); // Set your timezone

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

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

    return NotificationDetails(android: android, iOS: ios);
  }

  /// Convert event.id to a valid notification ID
  int _idFor(String id) => id.hashCode & 0x7fffffff;

  /// Schedule notification based on the event's reminder
  Future<void> scheduleNotification(Event event) async {
    await init();

    if (event.reminderBefore == null) return;

    final scheduledDate = event.dateTime.subtract(event.reminderBefore!);

    // Skip if date is already passed
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(scheduledDate, tz.local);

    final details = _buildDetails(event.type);

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

  /// Cancel individual notification
  Future<void> cancelNotification(String eventId) async {
    await init();
    await _plugin.cancel(_idFor(eventId));
  }

  /// Cancel ALL notifications
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
