import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
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

    // 🚫 Disable everything on web
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    // 1️⃣ Timezone Setup
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));

    // 2️⃣ Initialization settings + REQUIRED CALLBACKS
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // handle notification tap
        // (leave empty if you don't need to navigate)
      },
    );

    // 3️⃣ Runtime permission for Android 13+
    if (Platform.isAndroid) {
      final androidImpl =
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // ask for permissions
      await androidImpl?.requestNotificationsPermission();
    }

    // 4️⃣ iOS permission
    if (Platform.isIOS) {
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

  /// Build notification content
  NotificationDetails _buildDetails(EventType type) {
    AndroidNotificationDetails android;
    DarwinNotificationDetails ios;

    android = AndroidNotificationDetails(
      'default_channel',
      'Event Reminders',
      channelDescription: 'Notifications for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );

    ios = const DarwinNotificationDetails(
      sound: 'notification.wav', // must exist in iOS Runner folder
    );

    return NotificationDetails(android: android, iOS: ios);
  }

  int _idFor(String id) => id.hashCode & 0x7fffffff;

  Future<void> scheduleNotification(Event event) async {
    await init();
    if (kIsWeb) return;

    if (event.reminderBefore == null) return;

    final scheduledDate = event.dateTime.subtract(event.reminderBefore!);
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final details = _buildDetails(event.type);

    await _plugin.zonedSchedule(
      _idFor(event.id),
      event.title,
      event.subject ?? event.description ?? 'Upcoming event',
      tzDate,
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
