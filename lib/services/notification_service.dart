import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/event.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final androidDetails = AndroidNotificationDetails(
      'edunotif_channel',
      'EDUNOTIF Reminders',
      channelDescription: 'Reminders for exams and deadlines',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Just to ensure channel exists (Android 8+).
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'edunotif_channel',
        'EDUNOTIF Reminders',
        description: 'Reminders for exams and deadlines',
        importance: Importance.max,
      ),
    );
  }

  Future<void> scheduleNotification(Event event) async {
    if (event.reminderBefore == null) return;

    final scheduledTime = event.dateTime.subtract(event.reminderBefore!);
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      event.id.hashCode,
      event.title,
      event.subject ?? event.description ?? 'Upcoming event',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'edunotif_channel',
          'EDUNOTIF Reminders',
          channelDescription: 'Reminders for exams and deadlines',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelNotification(String eventId) async {
    await _flutterLocalNotificationsPlugin.cancel(eventId.hashCode);
  }
}
