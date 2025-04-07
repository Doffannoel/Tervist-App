import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tervist_apk/api/reminder_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;


class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Initialize notification plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize notification settings
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize time zones
      tz_init.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize settings for both platforms
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permission (for iOS)
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      _isInitialized = true;
      print("Notification service initialized successfully");
    } catch (e) {
      print("Error initializing notification service: $e");
    }
  }

  // Handle notification taps
  void _onNotificationTapped(NotificationResponse details) {
    // You can add navigation or other actions when the notification is tapped
    print('Notification tapped: ${details.payload}');
  }

  // Schedule a notification for a meal reminder
  Future<void> scheduleMealReminder(Reminder reminder) async {
    if (!_isInitialized) {
      print("Notification service not initialized, initializing now...");
      await init();
    }

    try {
      // Cancel any existing notifications for this meal type
      await cancelReminderByMealType(reminder.mealType);

      // If reminder is not active, just cancel and return
      if (!reminder.isActive) {
        print("Reminder not active, skipping scheduling");
        return;
      }

      // Parse the time string (HH:MM)
      final timeStr = reminder.time;
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) {
        print("Invalid time format: $timeStr");
        return;
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'meal_reminders_channel',
        'Meal Reminders',
        channelDescription: 'Notifications for meal reminders',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Generate unique ID for this meal type
      final notificationId = _getMealTypeNotificationId(reminder.mealType);

      // Schedule the notification for today at the specified time
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has already passed today, schedule for tomorrow
      final zonedScheduleTime = tz.TZDateTime.from(
        scheduledDate.isAfter(now)
            ? scheduledDate
            : scheduledDate.add(Duration(days: 1)),
        tz.local,
      );

      // Schedule the daily notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Time for ${reminder.mealType}!',
        'Don\'t forget to log your ${reminder.mealType.toLowerCase()} in the app.',
        zonedScheduleTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
        payload: reminder.mealType,
      );

      print('Scheduled ${reminder.mealType} reminder for ${reminder.time}');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Cancel a reminder notification by meal type
  Future<void> cancelReminderByMealType(String mealType) async {
    if (!_isInitialized) {
      print("Notification service not initialized, initializing now...");
      await init();
    }

    try {
      final notificationId = _getMealTypeNotificationId(mealType);
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      print('Cancelled ${mealType} reminder notification');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  // Cancel all reminder notifications
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) {
      print("Notification service not initialized, initializing now...");
      await init();
    }

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print('Cancelled all reminder notifications');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  // Generate a consistent notification ID for each meal type
  int _getMealTypeNotificationId(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return 1001;
      case 'Lunch':
        return 1002;
      case 'Dinner':
        return 1003;
      case 'Snack':
        return 1004;
      default:
        return 1000;
    }
  }
}
