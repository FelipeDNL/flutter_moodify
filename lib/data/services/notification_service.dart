import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_test/data/services/mood_music_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final MoodMusicService _moodService = MoodMusicService();

  // Constants
  static const int moodReminderId = 0;
  static const String channelId = 'mood_reminder';
  static const String channelName = 'Lembretes de Humor';
  static const String channelDescription =
      'Lembretes diários para registrar seu humor';

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Request permissions
    await requestPermissions();
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  /// Schedule daily mood reminder at 8 PM
  Future<void> scheduleDailyMoodReminder() async {
    // Cancel any existing notifications first
    await _notifications.cancel(moodReminderId);

    // Get the current local timezone
    final String currentTimeZone = await _getCurrentTimeZone();
    final location = tz.getLocation(currentTimeZone);

    // Schedule for 2 minutes from now (FOR TESTING ONLY)
    final now = tz.TZDateTime.now(location);
    var scheduledDate = now.add(const Duration(minutes: 2));

    /* // Schedule for 8 PM today (or tomorrow if already past 8 PM)
    final now = tz.TZDateTime.now(location);
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      20,
      0,
      0,
      0,
      0,
    ); */

    // If 8 PM today has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(tz.TZDateTime.now(location))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Notification details
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule the notification to repeat daily
    await _notifications.zonedSchedule(
      moodReminderId,
      'Não se esqueça do seu humor!',
      'Registre como você está se sentindo hoje e compartilhe sua música.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the mood reminder notification
  Future<void> cancelMoodNotification() async {
    await _notifications.cancel(moodReminderId);
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) async {
    // Check if mood has already been set today
    final hasMood = await _moodService.hasMusicToday();

    if (hasMood) {
      // If mood is already set, just open the app without showing the form
      // The app navigation will be handled by the system when app opens
      return;
    }

    // If mood is not set, the app will open normally and user can add mood
    // Navigation to specific screen would require a navigator key reference
  }

  /// Get current timezone (simplified - defaults to local)
  Future<String> _getCurrentTimeZone() async {
    try {
      // Try to get system timezone
      // This is a simplified approach - you may want to use flutter_native_timezone
      // or similar package for more accurate timezone detection
      return 'America/Sao_Paulo'; // Default to Brazil timezone
    } catch (e) {
      return 'UTC'; // Fallback to UTC
    }
  }
}
