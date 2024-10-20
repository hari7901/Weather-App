import '../models/models.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class AlertService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  AlertService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> triggerAlert(Alert alert) async {
    // Display notification
    await _showNotification(alert);

    // Send email (Optional)
    // await _sendEmail(alert);

    // Log to console
    print('ALERT: ${alert.message}');
  }

  Future<void> _showNotification(Alert alert) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'alert_channel',
      'Alerts',
      channelDescription: 'Channel for weather alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      'Weather Alert for ${alert.city}',
      alert.message,
      platformChannelSpecifics,
      payload: 'alert_payload',
    );
  }

}