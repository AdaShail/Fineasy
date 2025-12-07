import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  bool _permissionGranted = false;
  String? _fcmToken;
  final List<Map<String, dynamic>> _notifications = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get permissionGranted => _permissionGranted;
  String? get fcmToken => _fcmToken;
  List<Map<String, dynamic>> get notifications => _notifications;

  NotificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _notificationService.initialize();
      _permissionGranted = await _notificationService.requestPermission();

      if (_permissionGranted) {
        _fcmToken = await _notificationService.getFCMToken();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<void> requestPermission() async {
    _permissionGranted = await _notificationService.requestPermission();

    if (_permissionGranted && _fcmToken == null) {
      _fcmToken = await _notificationService.getFCMToken();
    }

    notifyListeners();
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_permissionGranted) return;

    _notificationService.showLocalNotification(title: title, message: body);
  }

  Future<void> schedulePaymentReminder({
    required String customerName,
    required double amount,
    required DateTime dueDate,
  }) async {
    if (!_permissionGranted) return;

    await _notificationService.scheduleNotification(
      title: 'Payment Reminder',
      message: '$customerName owes ₹${amount.toStringAsFixed(2)}',
      scheduledTime: dueDate,
    );
  }

  Future<void> scheduleSupplierPaymentReminder({
    required String supplierName,
    required double amount,
    required DateTime dueDate,
  }) async {
    if (!_permissionGranted) return;

    await _notificationService.scheduleNotification(
      title: 'Payment Due',
      message: 'Pay ₹${amount.toStringAsFixed(2)} to $supplierName',
      scheduledTime: dueDate,
    );
  }

  Future<void> notifyTransactionAdded({
    required String type,
    required double amount,
  }) async {
    if (!_permissionGranted) return;

    await showLocalNotification(
      title: 'Transaction Added',
      body: '$type of ₹${amount.toStringAsFixed(2)} recorded',
    );
  }

  Future<void> notifyDataSynced() async {
    if (!_permissionGranted) return;

    await showLocalNotification(
      title: 'Data Synced',
      body: 'Your data has been synchronized successfully',
    );
  }

  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markNotificationAsRead(int index) {
    if (index < _notifications.length) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  int get unreadNotificationsCount {
    return _notifications.where((n) => n['read'] != true).length;
  }
}
