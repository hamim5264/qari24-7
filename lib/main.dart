import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/network_service.dart';
import 'core/services/localization_service.dart';
import 'features/auth/services/auth_api_service.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/notification/services/notification_api_service.dart';
import 'features/notification/repositories/notification_repository.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/subscription/controllers/subscription_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final data = message.data;
    if (data.isNotEmpty && message.notification == null) {
      final title = data['title'] ?? data['titleKey'] ?? 'QARI 24/7';
      final body = data['body'] ?? data['descKey'] ?? '';

      final FlutterLocalNotificationsPlugin localNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await localNotificationsPlugin.initialize(initSettings);

      final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

      // Explicitly create the high-importance channel
      final highImportanceChannel = AndroidNotificationChannel(
        'high_importance_channel_v2',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
      );

      // Create the general channel as well to keep existing support
      const generalChannel = AndroidNotificationChannel(
        'qari_alerts_channel',
        'General Notifications',
        description: 'Streaks, goals, and library updates.',
        importance: Importance.max,
      );

      final androidPlugin = localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(highImportanceChannel);
        await androidPlugin.createNotificationChannel(generalChannel);
      }

      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel_v2',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await localNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        details,
      );
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  Get.put(LocalizationService());
  await Get.putAsync(() => ConnectivityService().init());
  await Get.putAsync(() => NetworkService().init());
  Get.put(AuthApiService());
  Get.put(AuthRepository());
  Get.put(NotificationApiService());
  Get.put(NotificationRepository());
  Get.put(SettingsController());
  Get.put(SubscriptionController());

  runApp(const QariApp());
}
