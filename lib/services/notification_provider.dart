import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  late List<AppNotification> _notifications = [];
  bool _isLoading = false;
  DateTime? _lastFetch;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount {
    int total = 0;
    for (var notification in _notifications) {
      total += notification.count;
    }
    return total;
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

  void markAsRead(String notificationId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].id == notificationId) {
        _notifications[i].read = true;
        notifyListeners();
        break;
      }
    }
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
