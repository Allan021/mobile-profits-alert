import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ChangeNotifier, Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

// Background message handler — must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) debugPrint('[Push] background: ${message.notification?.title}');
}

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'pa_alerts';
  static const _channelName = 'Market Alerts';
  static const _channelDesc = 'Real-time market signal alerts for your watchlist';

  /// Call once at app startup (after Firebase.initializeApp)
  Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) debugPrint('[Push] permission: ${settings.authorizationStatus}');

    // Android 13+ — request local notification permission explicitly
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ));

    // Init local notifications plugin (for foreground display)
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload);
      },
    );

    // iOS — show banner even in foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _handleNotificationTap(msg.data['item_id']);
    });

    // Handle notification tap when app was terminated
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _handleNotificationTap(initial.data['item_id']);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] getToken error: $e');
      return null;
    }
  }

  /// Register FCM token with backend after login
  Future<void> registerToken(ApiClient client) async {
    try {
      final token = await getToken();
      if (token == null) return;
      final platform = Platform.isIOS ? 'ios' : 'android';
      await client.post(ApiEndpoints.registerToken, data: {
        'token': token,
        'platform': platform,
      });
      if (kDebugMode) debugPrint('[Push] token registered platform=$platform');

      // Re-register whenever token refreshes
      _fcm.onTokenRefresh.listen((newToken) async {
        await client.post(ApiEndpoints.registerToken, data: {
          'token': newToken,
          'platform': platform,
        });
        if (kDebugMode) debugPrint('[Push] token refreshed and re-registered');
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] registerToken error: $e');
    }
  }

  /// Unregister token on logout
  Future<void> unregisterToken(ApiClient client) async {
    try {
      final token = await getToken();
      if (token == null) return;
      await client.post(ApiEndpoints.unregisterToken, data: {'token': token});
      if (kDebugMode) debugPrint('[Push] token unregistered');
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] unregisterToken error: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    if (kDebugMode) debugPrint('[Push] foreground: ${notification.title}');

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF10B981),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['item_id'],
    );
  }

  void _handleNotificationTap(String? itemId) {
    if (kDebugMode) debugPrint('[Push] tapped item_id=$itemId');
    pendingNavigationToAlerts = true;
    notifyListeners(); // triggers GoRouter redirect
  }

  // Pending navigation — consumed by app_router.dart via refreshListenable
  String? pendingNavigationItemId;
  bool pendingNavigationToAlerts = false;

  void clearPendingNavigation() {
    pendingNavigationItemId = null;
    pendingNavigationToAlerts = false;
    // intentionally no notifyListeners() — avoids redirect loop
  }
}
