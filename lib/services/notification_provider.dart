import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  late List<AppNotification> _notifications = [];
  bool _isLoading = false;
  DateTime? _lastFetch;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  
  // Count unread notifications properly
  int get unreadCount {
    return _notifications.where((n) => !n.read).length;
  }

  Future<void> fetchNotifications(int parentId) async {
    _isLoading = true;
    // Don't notify listeners on initial load - it causes build issues
    // Only notify after the async gap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final service = NotificationService();
      final notifs = await service.getNotifications(parentId);
      _notifications = service.sortByPriority(notifs);
      _lastFetch = DateTime.now();
    } catch (e) {
      print('Error in NotificationProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].id == notificationId) {
        _notifications[i].read = true;
        notifyListeners();
        
        // Call API to mark as read on backend
        try {
          final service = NotificationService();
          await service.markAsRead(notificationId);
        } catch (e) {
          print('Error marking notification as read: $e');
        }
        break;
      }
    }
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  bool shouldRefresh() {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!).inSeconds > 30; // Refresh every 30 seconds
  }
}
