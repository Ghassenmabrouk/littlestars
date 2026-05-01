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

    // Parse created_at timestamp
    DateTime? parsedCreatedAt;
    final createdAtField = json['created_at'] ?? json['timestamp'];
    if (createdAtField != null && createdAtField.toString().isNotEmpty) {
      try {
        // Handle ISO 8601 format with Z or without
        String timestampStr = createdAtField.toString();
        if (timestampStr.endsWith('Z')) {
          parsedCreatedAt = DateTime.parse(timestampStr);
        } else if (timestampStr.contains('T')) {
          // ISO 8601 without Z
          parsedCreatedAt = DateTime.parse(timestampStr);
        } else if (timestampStr.contains(' ')) {
          // PostgreSQL format: "2024-01-15 10:30:45"
          timestampStr = timestampStr.replaceFirst(' ', 'T');
          parsedCreatedAt = DateTime.parse(timestampStr);
        }
      } catch (e) {
        print('Error parsing timestamp: $createdAtField, error: $e');
      }
    }

    return AppNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? 'unknown',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      count: parsedCount > 0 ? parsedCount : 1,
      priority: json['priority'] ?? 'medium',
      createdAt: parsedCreatedAt,
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
      final response = await ApiService.getNotifications(parentId);
      
      if (response['success'] && response['data'] is List) {
        final notifications = (response['data'] as List)
            .map((n) => AppNotification.fromJson(n))
            .toList();
        return notifications;
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
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
