import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications: the daily close-day reminder and low-balance alerts.
/// No server involved. All methods fail soft: a missing permission or an
/// unsupported platform never breaks the app.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _closeReminderId = 1001;
  static const _closeChannel = AndroidNotificationDetails(
    'close_day',
    'Day-close reminder',
    channelDescription: 'Daily reminder to close the day',
    importance: Importance.defaultImportance,
  );
  static const _lowChannel = AndroidNotificationDetails(
    'low_balance',
    'Low balance',
    channelDescription: 'Warns when an account runs low',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> _ensureInit() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  /// Asks for the Android 13+ notification permission. Returns whether it
  /// is granted.
  Future<bool> requestPermission() async {
    try {
      await _ensureInit();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    } on Object {
      return false;
    }
  }

  /// Schedules (or replaces) the daily reminder at [hour]:00 Dhaka time.
  Future<void> scheduleCloseReminder({
    required int hour,
    required String title,
    required String body,
  }) async {
    try {
      await _ensureInit();
      final dhaka = tz.getLocation('Asia/Dhaka');
      final now = tz.TZDateTime.now(dhaka);
      var when = tz.TZDateTime(dhaka, now.year, now.month, now.day, hour);
      if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: _closeReminderId,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(android: _closeChannel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on Object {
      // Scheduling is best effort.
    }
  }

  /// One-off notification at [at] (an instant), for due-date reminders.
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    try {
      await _ensureInit();
      final when = tz.TZDateTime.from(at.toUtc(), tz.getLocation('Asia/Dhaka'));
      if (!when.isAfter(tz.TZDateTime.now(tz.getLocation('Asia/Dhaka')))) {
        return;
      }
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(android: _closeChannel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Object {
      // best effort
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _ensureInit();
      await _plugin.cancel(id: id);
    } on Object {
      // ignore
    }
  }

  Future<void> cancelCloseReminder() async {
    try {
      await _ensureInit();
      await _plugin.cancel(id: _closeReminderId);
    } on Object {
      // ignore
    }
  }

  Future<void> showLowBalance({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _ensureInit();
      await _plugin.show(
        id: 2000 + id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(android: _lowChannel),
      );
    } on Object {
      // ignore
    }
  }
}
