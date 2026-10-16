import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Всё про уведомления: FCM (push из Firebase) + показ уведомления на телефоне.
class NotificationService {
  // Плагин, который рисует уведомление в шторке Android
  static final _local = FlutterLocalNotificationsPlugin();

  // Токен устройства в FCM — по нему Firebase понимает, кому слать push
  static String? token;

  static Future<void> init() async {
    // 1. Настраиваем локальные уведомления (иконка = иконка приложения)
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // 2. Спрашиваем разрешение на уведомления (Android 13+)
    await FirebaseMessaging.instance.requestPermission();

    // 3. Получаем FCM-токен устройства.
    //    getToken помечен устаревшим, но именно этот токен просит
    //    Firebase Console для тестового push-сообщения.
    try {
      // ignore: deprecated_member_use
      token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM token: $token');
    } catch (e) {
      debugPrint('Не удалось получить FCM token: $e');
    }

    // 4. Push пришёл, когда приложение ОТКРЫТО.
    //    Android сам его не показывает — показываем вручную.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        show(notification.title ?? '', notification.body ?? '');
      }
    });
  }

  // Показать уведомление в шторке
  static Future<void> show(String title, String body) async {
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel', // id канала
          'Уведомления', // название канала в настройках телефона
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
