import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/notification_bell_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationService>(
        context,
        listen: false,
      ).loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.notifications)),
            Tab(text: 'Unread', icon: Icon(Icons.mark_email_unread)),
          ],
        ),
        actions: [
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'mark_all_read':
                      await notificationService.markAllAsRead();
                      break;
                    case 'clear_all':
                      notificationService.clearAll();
                      break;
                    case 'refresh':
                      await notificationService.loadNotifications();
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'mark_all_read',
                        child: Row(
                          children: [
                            Icon(Icons.done_all),
                            SizedBox(width: 8),
                            Text('Mark all as read'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 8),
                            Text('Refresh'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Clear all',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          if (notificationService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(
                notificationService.notifications,
                notificationService,
              ),
              _buildNotificationsList(
                notificationService.unreadNotifications,
                notificationService,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(
    List<AppNotification> notifications,
    NotificationService notificationService,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => notificationService.loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationListTile(
            notification: notification,
            onTap: () async {
              if (!notification.isRead) {
                await notificationService.markAsRead(notification.id);
              }

              // Handle notification action
              if (notification.actionUrl != null) {
                _handleNotificationAction(notification);
              }
            },
            onDismiss: () {
              notificationService.deleteNotification(notification.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _handleNotificationAction(AppNotification notification) {
    // Handle different types of notification actions
    switch (notification.type) {
      case NotificationType.invoice:
        // Navigate to invoice details
        Navigator.pushNamed(context, '/invoices');
        break;
      case NotificationType.payment:
        // Navigate to payments
        Navigator.pushNamed(context, '/payments');
        break;
      case NotificationType.compliance:
        // Navigate to compliance
        Navigator.pushNamed(context, '/compliance');
        break;
      case NotificationType.reminder:
        // Handle reminder action
        _showReminderDialog(notification);
        break;
      default:
        // Default action or no action
        break;
    }
  }

  void _showReminderDialog(AppNotification notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(notification.title),
            content: Text(notification.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Dismiss'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle reminder action based on notification data
                },
                child: const Text('Take Action'),
              ),
            ],
          ),
    );
  }
}
