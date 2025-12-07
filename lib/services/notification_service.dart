import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

enum NotificationType {
  info,
  warning,
  error,
  success,
  reminder,
  payment,
  invoice,
  compliance,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.info,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
      data: json['data'],
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'data': data,
      'action_url': actionUrl,
    };
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      data: data,
      actionUrl: actionUrl,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;

  /// Initialize notification service
  Future<void> initialize() async {
    await loadNotifications();
  }

  /// Load notifications from server
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> notificationsJson = data['notifications'] ?? [];
          _notifications.clear();
          _notifications.addAll(
            notificationsJson.map((json) => AppNotification.fromJson(json)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/v1/notifications/$notificationId/acknowledge',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/mark-all-read'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/$notificationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Add local notification (for immediate feedback)
  void addLocalNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    final notification = AppNotification(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      data: data,
      actionUrl: actionUrl,
    );

    _notifications.insert(0, notification);
    notifyListeners();

    // Auto-remove local notifications after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _notifications.removeWhere((n) => n.id == notification.id);
      notifyListeners();
    });
  }

  /// Show notification snackbar
  void showSnackbar(BuildContext context, AppNotification notification) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    notification.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        action:
            notification.actionUrl != null
                ? SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    // Handle action URL navigation
                  },
                )
                : null,
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.payment:
        return Colors.blue;
      case NotificationType.invoice:
        return Colors.purple;
      case NotificationType.compliance:
        return Colors.amber;
      case NotificationType.reminder:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.invoice:
        return Icons.receipt;
      case NotificationType.compliance:
        return Icons.verified;
      case NotificationType.reminder:
        return Icons.alarm;
      default:
        return Icons.info;
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Schedule notification (for compatibility with existing code)
  Future<void> scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledTime,
    NotificationType type = NotificationType.reminder,
  }) async {
    // For now, just add as local notification
    // In a real implementation, this would schedule with the system
    addLocalNotification(title: title, message: message, type: type);
  }

  /// Show local notification (for compatibility)
  void showLocalNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    addLocalNotification(title: title, message: message, type: type);
  }

  /// Cancel notification (for compatibility)
  Future<void> cancelNotification(String notificationId) async {
    await deleteNotification(notificationId);
  }

  /// Show payment reminder notification
  void showPaymentReminderNotification({
    required String customerName,
    required double amount,
    required String invoiceNumber,
  }) {
    addLocalNotification(
      title: 'Payment Reminder',
      message:
          'Payment of ₹${amount.toStringAsFixed(2)} due from $customerName for invoice $invoiceNumber',
      type: NotificationType.reminder,
    );
  }

  /// Show supplier reminder notification
  void showSupplierReminderNotification({
    required String supplierName,
    required double amount,
    required String description,
  }) {
    addLocalNotification(
      title: 'Supplier Payment Due',
      message:
          'Payment of ₹${amount.toStringAsFixed(2)} due to $supplierName for $description',
      type: NotificationType.reminder,
    );
  }

  /// Get FCM token (for compatibility)
  Future<String?> getFCMToken() async {
    // Return null for now - would implement FCM in real app
    return null;
  }

  /// Request permission (for compatibility)
  Future<bool> requestPermission() async {
    // Return true for now - would implement permission request in real app
    return true;
  }

  /// Send notification (for compatibility with other services)
  Future<void> sendNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      // Send to server
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'message': message,
          'type': type.toString().split('.').last,
          'data': data,
          'action_url': actionUrl,
        }),
      );

      if (response.statusCode == 200) {
        // Also add locally for immediate display
        _addLocalNotification(
          title: title,
          message: message,
          type: type,
          data: data,
          actionUrl: actionUrl,
        );
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      // Fallback to local notification
      _addLocalNotification(
        title: title,
        message: message,
        type: type,
        data: data,
        actionUrl: actionUrl,
      );
    }
  }

  /// Add local notification (private helper method)
  void _addLocalNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      data: data,
      actionUrl: actionUrl,
    );

    _notifications.add(notification);
  }
}
