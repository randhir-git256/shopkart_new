import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Handle notification tap when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
      );
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    print('FCM Token: $token'); // Log the token
    return token;
  }

  // Subscribe to topics for different notification types
  Future<void> subscribeToTopics(String userId, String userRole) async {
    // Subscribe to new products topic (for all users)
    await _messaging.subscribeToTopic('new_products');

    // Subscribe to user-specific order updates
    await _messaging.subscribeToTopic('order_updates_$userId');

    // Store FCM token in Firestore
    final token = await getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'topics': ['new_products', 'order_updates_$userId'],
      });
    }
  }

  Future<void> unsubscribeFromTopics(String userId) async {
    await _messaging.unsubscribeFromTopic('new_products');
    await _messaging.unsubscribeFromTopic('order_updates_$userId');
  }
}

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
