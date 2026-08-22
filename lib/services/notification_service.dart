import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'analytics_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AnalyticsService _analytics = AnalyticsService();

  // Callback to show in-app alert when notification fires on web
  static void Function(String title, String body)? onWebNotificationReceived;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      _initialized = true;
      debugPrint('Notification Service: Initialized for Web platform.');
      return;
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: null, // Basic setup
          );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      _initialized = true;
      debugPrint(
        'Notification Service: Initialized for Mobile/Native platform.',
      );
    } catch (e) {
      debugPrint('Failed to initialize local notifications: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      debugPrint('Notification Service: Permission mock approved for web.');
      return true;
    }

    try {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notifications permissions: $e');
    }
    return false;
  }

  Future<void> triggerTestNotification() async {
    const String title = 'Habitt Reminder!';
    const String body =
        'Don\'t forget to drink water and complete your daily habits today!';

    // Log event
    await _analytics.logEvent('test_notification_triggered', {
      'title': title,
      'body': body,
    });

    if (kIsWeb) {
      // Trigger Web toast dialog callback
      if (onWebNotificationReceived != null) {
        onWebNotificationReceived!(title, body);
      } else {
        debugPrint('Notification alert (web console): $title - $body');
      }
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'habitt_reminders_channel', // Channel ID
            'Habit Reminders', // Channel Name
            channelDescription: 'Channel for habit tracking daily reminders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        0,
        title,
        body,
        platformDetails,
        payload: 'test_reminder',
      );
    } catch (e) {
      debugPrint('Error displaying notification: $e');
      // If native fails (e.g. windows desktop mock/missing assets), fallback to callback
      if (onWebNotificationReceived != null) {
        onWebNotificationReceived!(
          title,
          '$body (Fallback: Native Notification Failed: $e)',
        );
      }
    }
  }
}
