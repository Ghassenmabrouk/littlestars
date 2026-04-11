import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  late FlutterLocalNotificationsPlugin _localNotifications;

  factory FCMService() {
    return _instance;
  }

  FCMService._internal();

  Future<void> initialize() async {
    // Request notification permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    _initializeLocalNotifications();

    // Get FCM token and save it
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      // Save token after a small delay to ensure user context is available
      Future.delayed(const Duration(seconds: 1), () async {
        await _saveFCMTokenToDatabase(token);
      });
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message);
    });

    // Handle terminated state messages
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      print('FCM Token refreshed: $token');
      await _saveFCMTokenToDatabase(token);
    });
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    _localNotifications = FlutterLocalNotificationsPlugin();
    _localNotifications.initialize(initSettings);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    // TODO: Navigate to appropriate screen based on message data
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'notifications_channel',
      'Notifications',
      channelDescription: 'Notifications from Jardin Enfant',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: data != null ? data.toString() : null,
    );
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> _saveFCMTokenToDatabase(String token) async {
    try {
      // Try to get parent ID from SharedPreferences (saved during login)
      final prefs = await SharedPreferencesService.getInstance();
      final parentId = await prefs.getParentId();

      if (parentId == null) {
        print('Warning: Could not save FCM token - parent ID not found');
        return;
      }

      // Call backend API to save token
      final url = Uri.parse('http://192.168.1.104/jardin_enfant_ghofrane/save_fcm_token_api.php');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'parent_id': parentId,
          'fcm_token': token,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          print('FCM token saved successfully');
        } else {
          print('Error saving FCM token: ${result['error']}');
        }
      } else {
        print('Failed to save FCM token: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while saving FCM token: $e');
    }
  }
}

// SharedPreferences wrapper service
class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  late final dynamic _prefs; // Using dynamic to avoid importing shared_preferences here

  SharedPreferencesService._internal(dynamic prefs) {
    _prefs = prefs;
  }

  static Future<SharedPreferencesService> getInstance() async {
    if (_instance == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _instance = SharedPreferencesService._internal(prefs);
    }
    return _instance!;
  }

  Future<int?> getParentId() async {
    return _prefs.getInt('parent_id');
  }
}

