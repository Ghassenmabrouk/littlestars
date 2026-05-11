import 'package:flutter/material.dart';
import 'api_service.dart';

class AppNotification {
  final String id;
  final String type; // 'message', 'invoice', 'attendance', 'announcement'
  final String title;
  final String message;
  final int count;
  final String priority; // 'high', 'medium', 'low'
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.count,
    required this.priority,
    DateTime? createdAt,
    this.read = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    final parsedCount = rawCount is int
        ? rawCount
        : (int.tryParse(rawCount?.toString() ?? '') ?? 1);

    // Parse timestamp from various possible field names
    DateTime? parsedDateTime;
    final possibleTimestampFields = ['created_at', 'timestamp', 'date_created', 'createdAt', 'date'];

    for (final field in possibleTimestampFields) {
      if (json[field] != null) {
        try {
          if (json[field] is String) {
            // Try parsing as ISO 8601 string
            parsedDateTime = DateTime.parse(json[field]);
          } else if (json[field] is int) {
            // Try parsing as Unix timestamp (seconds)
            parsedDateTime = DateTime.fromMillisecondsSinceEpoch(json[field] * 1000);
          }
          if (parsedDateTime != null) break;
        } catch (e) {
          print('Error parsing timestamp field "$field": $e');
        }
      }
    }

    return AppNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? 'unknown',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      count: parsedCount > 0 ? parsedCount : 1,
      priority: json['priority'] ?? 'medium',
      createdAt: parsedDateTime, // Will default to DateTime.now() if null
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<List<AppNotification>> getNotifications(int parentId) async {
    try {
      print('[NotificationService] Fetching notifications for parent_id: $parentId');
      final response = await ApiService.getNotifications(parentId);
      
      print('[NotificationService] API Response: $response');
      
      // Check if response is success and has data
      if (response['success'] == true) {
        if (response['data'] is List) {
          final notifications = (response['data'] as List)
              .map((n) => AppNotification.fromJson(n))
              .toList();
          print('[NotificationService] Parsed ${notifications.length} notifications');
          return notifications;
        } else {
          print('[NotificationService] Data is not a list: ${response['data'].runtimeType}');
          return [];
        }
      } else {
        print('[NotificationService] API returned success=false or error: ${response['message'] ?? response['error'] ?? 'Unknown error'}');
        return [];
      }
    } catch (e, stackTrace) {
      print('[NotificationService] ERROR: $e');
      print('[NotificationService] Stack trace: $stackTrace');
      return [];
    }
  }

  int getTotalUnreadCount(List<AppNotification> notifications) {
    return notifications.fold(0, (sum, n) => sum + n.count);
  }

  List<AppNotification> filterByType(List<AppNotification> notifications, String type) {
    return notifications.where((n) => n.type == type).toList();
  }

  List<AppNotification> sortByPriority(List<AppNotification> notifications) {
    final priorityMap = {'high': 0, 'medium': 1, 'low': 2};
    return List.from(notifications)
      ..sort((a, b) => (priorityMap[a.priority] ?? 2).compareTo(priorityMap[b.priority] ?? 2));
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.markNotificationAsRead(notificationId);
      if (response['success']) {
        print('Notification marked as read: $notificationId');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}
