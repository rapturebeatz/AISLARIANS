import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(firestoreServiceProvider));
});

class NotificationService {
  final FirestoreService _firestore;
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._firestore);

  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    _messaging.onTokenRefresh.listen(_saveToken);
    _messaging.onMessage.listen(_handleForegroundMessage);
    _messaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    await _localNotifications.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  Future<void> _saveToken(String token) async {
    // Save FCM token to Firestore for sending notifications
    await _firestore.update('users', 'current-user', {'fcmToken': token});
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails('aislar_channel', 'AISLAR Connect', importance: Importance.high, priority: Priority.high);
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: message.data['screen'],
    );

    // Save to Firestore notifications collection
    await _firestore.create('notifications', {
      'recipientId': 'current-user',
      'type': message.data['type'] ?? 'system',
      'title': notification.title ?? '',
      'body': notification.body ?? '',
      'data': {'screen': message.data['screen'] ?? '', 'id': message.data['id']},
      'isRead': false,
    });
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    // Navigate to relevant screen based on message data
  }

  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    String? screen,
    String? id,
  }) async {
    // In production, use Cloud Functions to send via FCM Admin SDK
    await _firestore.create('notifications', {
      'recipientId': recipientId,
      'type': type,
      'title': title,
      'body': body,
      'data': {'screen': screen ?? '', 'id': id},
      'isRead': false,
      'createdAt': DateTime.now(),
    });
  }
}
