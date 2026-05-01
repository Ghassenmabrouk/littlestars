import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/notification_provider.dart';
import '../services/notification_service.dart';
import '../theme/kg_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<void> _refreshFuture;
  
  @override
  void initState() {
    super.initState();
    // Auto-refresh notifications every 10 seconds when screen is active
    _startAutoRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final notifProvider = context.read<NotificationProvider>();
      if (authProvider.user != null) {
        notifProvider.fetchNotifications(authProvider.user!.id);
      }
    });
  }
  
  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final notifProvider = context.read<NotificationProvider>();
        if (authProvider.user != null) {
          notifProvider.fetchNotifications(authProvider.user!.id).then((_) => _startAutoRefresh());
        }
      }
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: KG.primary,
        foregroundColor: Colors.white,
        leading: const Text('🔔', style: TextStyle(fontSize: 24, color: Colors.white)),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final unread = provider.unreadCount;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔔', style: TextStyle(fontSize: 64, color: Colors.grey[400])),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune Notification',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous recevrez les notifications ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.user != null) {
                await provider.fetchNotifications(authProvider.user!.id);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...provider.notifications.map((notif) {
                  return NotificationCard(
                    notification: notif,
                    onMarkAsRead: () => provider.markAsRead(notif.id),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onMarkAsRead,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getBackgroundColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.withOpacity(0.1);
      case 'medium':
        return Colors.orange.withOpacity(0.1);
      case 'low':
        return Colors.blue.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  String _getTypeEmoji(String type) {
    switch (type) {
      case 'message':
        return '💬';
      case 'invoice':
        return '🧾';
      case 'attendance':
        return '⚠️';
      case 'announcement':
      case 'notification':
        return '📢';
      default:
        return '🔔';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMarkAsRead,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.read 
              ? Colors.grey[50] 
              : _getBackgroundColor(notification.priority),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.read 
                ? Colors.grey.withOpacity(0.2)
                : _getPriorityColor(notification.priority).withOpacity(0.3),
            width: notification.read ? 1 : 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 8),
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPriorityColor(notification.priority).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getTypeEmoji(notification.type),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: notification.read ? Colors.grey[600] : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification.priority),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.read ? Colors.grey[600] : Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (!notification.read)
                          GestureDetector(
                            onTap: onMarkAsRead,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: KG.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Marquer comme lu',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: KG.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
