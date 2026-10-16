import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'pages/registration_page.dart';
import 'services/notification_service.dart';

// Push пришёл, когда приложение ЗАКРЫТО или свёрнуто.
// Android сам покажет уведомление, здесь можно только обработать данные.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Push в фоне: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Подключаемся к Firebase (данные берутся из google-services.json)
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    await NotificationService.init();
  } catch (e) {
    // Нет google-services.json — форма откроется, но сохранить не получится
    debugPrint('Firebase не настроен: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RegistrationPage(),
    );
  }
}
