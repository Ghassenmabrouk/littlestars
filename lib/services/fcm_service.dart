import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  factory FCMService() {
    return _instance;
  }

  FCMService._internal();

  Future<void> initialize() async {
    try {
      // Request notification permission
      print('[FCM] Requesting notification permissions...');
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('[FCM] Notification permissions granted');

      // Get FCM token and save it
      print('[FCM] Getting FCM token...');
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('[FCM] Token obtained: $token');
        // Save token after a small delay to ensure user context is available
        Future.delayed(const Duration(seconds: 1), () async {
          await _saveFCMTokenToDatabase(token);
        });
      } else {
        print('[FCM] WARNING: Could not obtain FCM token');
      }

      // Handle foreground messages
      print('[FCM] Setting up foreground message handler...');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // Handle background messages
      print('[FCM] Setting up message opened handler...');
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageOpenedApp(message);
      });

      // Handle terminated state messages
      print('[FCM] Checking for initial message...');
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Listen for token refresh
      print('[FCM] Setting up token refresh listener...');
      _firebaseMessaging.onTokenRefresh.listen((String token) async {
        print('[FCM] Token refreshed: $token');
        await _saveFCMTokenToDatabase(token);
      });
      
      print('[FCM] Initialization complete!');
    } catch (e) {
      print('[FCM] ERROR during initialization: $e');
      print('[FCM] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    // Firebase displays system notification automatically for foreground messages
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    // Notification tapped - could navigate to relevant screen based on message.data
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
      final url = Uri.parse('http://192.168.1.21/jardin_enfant_ghofrane/save_fcm_token_api.php');
      
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

