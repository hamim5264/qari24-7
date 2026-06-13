import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../services/notification_api_service.dart';
import '../../auth/repositories/auth_repository.dart';
import '../screens/notification_screen.dart';

class NotificationRepository extends GetxService {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  late final NotificationApiService _apiService;
  late final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  static const String _keyNotifications = 'notification_list_cache';

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<NotificationApiService>();
    _initLocalNotifications();
    _setupFcmListeners();
    loadCachedNotifications();

    // Auto-fetch and register device when logged in
    final authRepo = Get.find<AuthRepository>();
    if (authRepo.isLogged.value) {
      fetchNotifications();
      registerCurrentDeviceToken();
    }

    ever(authRepo.isLogged, (bool logged) {
      if (logged) {
        fetchNotifications();
        registerCurrentDeviceToken();
      } else {
        notifications.clear();
        _clearCache();
      }
    });
  }

  /// Initialise Local Notifications
  Future<void> _initLocalNotifications() async {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToNotificationScreen();
      },
    );

    // Create the channel explicitly on Android to ensure it exists for background notifications
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    final highImportanceChannel = AndroidNotificationChannel(
      'high_importance_channel_v2',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );

    const generalChannel = AndroidNotificationChannel(
      'qari_alerts_channel',
      'General Notifications',
      description: 'Streaks, goals, and library updates.',
      importance: Importance.max,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(highImportanceChannel);
      await androidPlugin.createNotificationChannel(generalChannel);
    }

    // Handle launching app from terminated state via local notification
    try {
      final launchDetails = await _localNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        debugPrint("Local notification launched app from terminated state");
        _navigateToNotificationScreen();
      }
    } catch (e) {
      debugPrint("Error fetching notification launch details: $e");
    }
  }

  /// Setup Firebase Messaging Listeners
  Future<void> _setupFcmListeners() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Show banner/sound/badge when the app is in the foreground
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Banners
      badge: true, // App icon badges
      sound: true, // Notification sound
    );

    // Request permission on Android 13+
    try {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint("Error requesting Android notifications permission: $e");
    }

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("FCM Foreground message: ${message.messageId}");
      _showLocalNotification(message);
      fetchNotifications();
    });

    // Tap on background notification listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("FCM App opened from notification: ${message.messageId}");
      fetchNotifications();
      _navigateToNotificationScreen();
    });

    // Handle launching app from terminated state via FCM push notification
    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          "FCM App launched from notification: ${initialMessage.messageId}",
        );
        fetchNotifications();
        _navigateToNotificationScreen();
      }
    } catch (e) {
      debugPrint("Error fetching initial FCM message: $e");
    }
  }

  /// Display Foreground Notification using Local Notifications
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final channelId =
        message.notification?.android?.channelId ??
        'high_importance_channel_v2';
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'high_importance_channel_v2'
          ? 'High Importance Notifications'
          : 'General Notifications',
      channelDescription: channelId == 'high_importance_channel_v2'
          ? 'This channel is used for important notifications.'
          : 'Streaks, goals, and library updates.',
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

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  /// Get current FCM token and register it
  Future<void> registerCurrentDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await registerDevice(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        registerDevice(newToken);
      });
    } catch (e) {
      debugPrint("FCM token retrieval failed: $e");
    }
  }

  /// Register token on backend
  Future<void> registerDevice(String token) async {
    try {
      final response = await _apiService.registerDevice(token: token);
      debugPrint("Device registered on backend. Response: ${response.data}");
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('token')) {
          final errs = data['token'];
          if (errs is List &&
              errs.isNotEmpty &&
              errs.first.toString().contains("already exists")) {
            debugPrint(
              "Device token is already registered on backend (safe/success).",
            );
            return;
          }
        }
        debugPrint("FCM Backend register error details: ${e.response?.data}");
        debugPrint(
          "FCM Backend register status code: ${e.response?.statusCode}",
        );
      }
      debugPrint("FCM Backend register error: $e");
    }
  }

  /// Unregister token on backend
  Future<void> unregisterDevice(String token) async {
    try {
      final response = await _apiService.unregisterDevice(token: token);
      debugPrint(
        "Device token deleted from backend. Response: ${response.data}",
      );
    } catch (e) {
      if (e is DioException) {
        debugPrint("FCM Backend unregister error details: ${e.response?.data}");
        debugPrint(
          "FCM Backend unregister status code: ${e.response?.statusCode}",
        );
      }
      debugPrint("FCM Backend unregister error: $e");
    }
  }

  /// Load cached notifications from SharedPreferences
  Future<void> loadCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = prefs.getString(_keyNotifications);
      if (cache != null && cache.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cache);
        final list = decoded
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        notifications.assignAll(list);
      }
    } catch (e) {
      debugPrint("Error reading notification cache: $e");
    }
  }

  /// Save notifications to cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_keyNotifications, jsonEncode(listJson));
    } catch (e) {
      debugPrint("Error caching notifications: $e");
    }
  }

  /// Clear notifications cache
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyNotifications);
    } catch (_) {}
  }

  /// Fetch notifications from backend
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getNotifications();
      final data = response.data;
      if (data is List) {
        final list = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        notifications.assignAll(list);
        await _saveToCache();
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint(
          "Failed to fetch notifications from backend: ${e.response?.data}",
        );
      }
      debugPrint("Failed to fetch notifications from backend: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead.value = true;
      _saveToCache();

      try {
        await _apiService.updateNotifications(
          data: {'id': int.tryParse(id) ?? id, 'is_read': true},
        );
      } catch (e) {
        debugPrint("Failed to update notification read status on server: $e");
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (var n in notifications) {
      n.isRead.value = true;
    }
    _saveToCache();

    try {
      await _apiService.updateNotifications(data: {'is_read': true});
    } catch (e) {
      debugPrint("Failed to mark all as read on server: $e");
    }
  }

  /// Mark section (today/yesterday) as read
  Future<void> markSectionAsRead(String category) async {
    final List<String> affectedIds = [];
    for (var n in notifications) {
      if (n.dayCategory.toLowerCase() == category.toLowerCase()) {
        n.isRead.value = true;
        affectedIds.add(n.id);
      }
    }
    _saveToCache();

    for (final id in affectedIds) {
      try {
        await _apiService.updateNotifications(
          data: {'id': int.tryParse(id) ?? id, 'is_read': true},
        );
      } catch (_) {}
    }
  }

  /// Navigate to Notification Screen safely
  void _navigateToNotificationScreen() {
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.to(() => const NotificationScreen());
    });
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    notifications.clear();
    await _clearCache();
    // Usually backend doesn't support bulk deletion or we call DELETE endpoint if it exists.
    // For now we clear locally to give instant response.
  }
}
