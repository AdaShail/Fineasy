import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/transaction_model.dart';
import 'whatsapp_service.dart';
import 'notification_service.dart';

enum ReminderType { payment, dueDate, custom }

enum ReminderFrequency { once, daily, weekly, monthly }

class ReminderModel {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final ReminderType type;
  final ReminderFrequency frequency;
  final bool isActive;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.type,
    this.frequency = ReminderFrequency.once,
    this.isActive = true,
    this.data = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'scheduledTime': scheduledTime.toIso8601String(),
    'type': type.toString().split('.').last,
    'frequency': frequency.toString().split('.').last,
    'isActive': isActive,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    scheduledTime: DateTime.parse(json['scheduledTime']),
    type: ReminderType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
      orElse: () => ReminderType.custom,
    ),
    frequency: ReminderFrequency.values.firstWhere(
      (e) => e.toString().split('.').last == json['frequency'],
      orElse: () => ReminderFrequency.once,
    ),
    isActive: json['isActive'] ?? true,
    data: Map<String, dynamic>.from(json['data'] ?? {}),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class ReminderService {
  static const String _remindersKey = 'scheduled_reminders';

  /// Initialize reminder service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await service.startService();
    await _loadAndScheduleReminders();
  }

  /// Save reminder to local storage
  static Future<void> _saveReminder(ReminderModel reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getAllReminders();
    reminders.removeWhere((r) => r.id == reminder.id);
    reminders.add(reminder);

    final jsonList = reminders.map((r) => r.toJson()).toList();
    await prefs.setString(_remindersKey, jsonEncode(jsonList));
  }

  /// Get all reminders from local storage
  static Future<List<ReminderModel>> getAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_remindersKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ReminderModel.fromJson(json)).toList();
  }

  /// Load and schedule all active reminders
  static Future<void> _loadAndScheduleReminders() async {
    final reminders = await getAllReminders();
    final now = DateTime.now();

    for (final reminder in reminders) {
      if (reminder.isActive && reminder.scheduledTime.isAfter(now)) {
        await _scheduleNotificationForReminder(reminder);
      }
    }
  }

  /// Schedule notification for a reminder
  static Future<void> _scheduleNotificationForReminder(
    ReminderModel reminder,
  ) async {
    await NotificationService().scheduleNotification(
      title: reminder.title,
      message: reminder.description,
      scheduledTime: reminder.scheduledTime,
    );
  }

  /// Schedule payment reminder for a customer with custom time
  static Future<String> schedulePaymentReminder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required double amount,
    required String currency,
    required DateTime scheduledTime,
    DateTime? dueDate,
    String? businessName,
    ReminderFrequency frequency = ReminderFrequency.once,
    bool sendWhatsApp = true,
    bool sendNotification = true,
  }) async {
    try {
      final reminderId =
          'payment_${customerId}_${DateTime.now().millisecondsSinceEpoch}';

      final reminder = ReminderModel(
        id: reminderId,
        title: 'Payment Reminder',
        description:
            'Payment reminder for $customerName: $currency ${amount.toStringAsFixed(2)}',
        scheduledTime: scheduledTime,
        type: ReminderType.payment,
        frequency: frequency,
        data: {
          'customerId': customerId,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'amount': amount,
          'currency': currency,
          'dueDate': dueDate?.toIso8601String(),
          'businessName': businessName,
          'sendWhatsApp': sendWhatsApp,
          'sendNotification': sendNotification,
        },
        createdAt: DateTime.now(),
      );

      await _saveReminder(reminder);
      await _scheduleNotificationForReminder(reminder);

      return reminderId;
    } catch (e) {
      throw Exception('Error scheduling payment reminder: $e');
    }
  }

  /// Schedule supplier payment reminder with custom time
  static Future<String> scheduleSupplierReminder({
    required String supplierId,
    required String supplierName,
    required String supplierPhone,
    required double amount,
    required String currency,
    required DateTime scheduledTime,
    DateTime? dueDate,
    String? businessName,
    ReminderFrequency frequency = ReminderFrequency.once,
    bool sendWhatsApp = true,
    bool sendNotification = true,
  }) async {
    try {
      final reminderId =
          'supplier_${supplierId}_${DateTime.now().millisecondsSinceEpoch}';

      final reminder = ReminderModel(
        id: reminderId,
        title: 'Supplier Payment Reminder',
        description:
            'Payment reminder for $supplierName: $currency ${amount.toStringAsFixed(2)}',
        scheduledTime: scheduledTime,
        type: ReminderType.payment,
        frequency: frequency,
        data: {
          'supplierId': supplierId,
          'supplierName': supplierName,
          'supplierPhone': supplierPhone,
          'amount': amount,
          'currency': currency,
          'dueDate': dueDate?.toIso8601String(),
          'businessName': businessName,
          'sendWhatsApp': sendWhatsApp,
          'sendNotification': sendNotification,
        },
        createdAt: DateTime.now(),
      );

      await _saveReminder(reminder);
      await _scheduleNotificationForReminder(reminder);

      return reminderId;
    } catch (e) {
      throw Exception('Error scheduling supplier reminder: $e');
    }
  }

  /// Schedule custom reminder with time selection
  static Future<String> scheduleCustomReminder({
    required String title,
    required String description,
    required DateTime scheduledTime,
    ReminderFrequency frequency = ReminderFrequency.once,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      final reminderId = 'custom_${DateTime.now().millisecondsSinceEpoch}';

      final reminder = ReminderModel(
        id: reminderId,
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        type: ReminderType.custom,
        frequency: frequency,
        data: data,
        createdAt: DateTime.now(),
      );

      await _saveReminder(reminder);
      await _scheduleNotificationForReminder(reminder);

      return reminderId;
    } catch (e) {
      throw Exception('Error scheduling custom reminder: $e');
    }
  }

  /// Cancel reminder by ID
  static Future<void> cancelReminder(String reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reminders = await getAllReminders();

      reminders.removeWhere((r) => r.id == reminderId);

      final jsonList = reminders.map((r) => r.toJson()).toList();
      await prefs.setString(_remindersKey, jsonEncode(jsonList));

      await NotificationService().cancelNotification(
        reminderId.hashCode.toString(),
      );
    } catch (e) {
      throw Exception('Error cancelling reminder: $e');
    }
  }

  /// Update reminder
  static Future<void> updateReminder(ReminderModel reminder) async {
    try {
      await _saveReminder(reminder);

      // Cancel old notification and schedule new one
      await NotificationService().cancelNotification(
        reminder.id.hashCode.toString(),
      );

      if (reminder.isActive && reminder.scheduledTime.isAfter(DateTime.now())) {
        await _scheduleNotificationForReminder(reminder);
      }
    } catch (e) {
      throw Exception('Error updating reminder: $e');
    }
  }

  /// Get reminders by type
  static Future<List<ReminderModel>> getRemindersByType(
    ReminderType type,
  ) async {
    final reminders = await getAllReminders();
    return reminders.where((r) => r.type == type).toList();
  }

  /// Get active reminders
  static Future<List<ReminderModel>> getActiveReminders() async {
    final reminders = await getAllReminders();
    return reminders.where((r) => r.isActive).toList();
  }

  /// Get upcoming reminders (next 7 days)
  static Future<List<ReminderModel>> getUpcomingReminders() async {
    final reminders = await getAllReminders();
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return reminders
        .where(
          (r) =>
              r.isActive &&
              r.scheduledTime.isAfter(now) &&
              r.scheduledTime.isBefore(nextWeek),
        )
        .toList();
  }

  /// Schedule daily check for due payments
  static Future<void> scheduleDailyDueCheck() async {
    try {
      final service = FlutterBackgroundService();
      await service.startService();

      // Schedule daily reminder at 9 AM
      final now = DateTime.now();
      var nextCheck = DateTime(now.year, now.month, now.day, 9, 0);

      if (nextCheck.isBefore(now)) {
        nextCheck = nextCheck.add(const Duration(days: 1));
      }

      await scheduleCustomReminder(
        title: 'Daily Payment Check',
        description: 'Check for overdue payments and send reminders',
        scheduledTime: nextCheck,
        frequency: ReminderFrequency.daily,
        data: {'type': 'daily_check'},
      );
    } catch (e) {
      throw Exception('Error scheduling daily due check: $e');
    }
  }

  /// Send immediate payment reminder
  static Future<bool> sendImmediateReminder({
    required CustomerModel customer,
    required double amount,
    required String currency,
    required DateTime dueDate,
    String? businessName,
    bool sendWhatsApp = true,
    bool sendNotification = true,
  }) async {
    bool success = true;

    try {
      if (sendWhatsApp) {
        final whatsappSent =
            await WhatsAppService.sendPaymentReminderWithDetails(
              phoneNumber: customer.phone ?? '',
              customerName: customer.name,
              amount: amount,
              invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
              dueDate: dueDate,
            );
        if (!whatsappSent) success = false;
      }

      if (sendNotification) {
        NotificationService().showPaymentReminderNotification(
          customerName: customer.name,
          amount: amount,
          invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } catch (e) {
      success = false;
    }

    return success;
  }

  /// Send immediate supplier reminder
  static Future<bool> sendImmediateSupplierReminder({
    required SupplierModel supplier,
    required double amount,
    required String currency,
    required DateTime dueDate,
    String? businessName,
    bool sendWhatsApp = true,
    bool sendNotification = true,
  }) async {
    bool success = true;

    try {
      if (sendWhatsApp) {
        final whatsappSent = await WhatsAppService.sendPaymentRequest(
          phoneNumber: supplier.phone ?? '',
          customerName: supplier.name,
          amount: amount,
          description: 'Payment due for services',
        );
        if (!whatsappSent) success = false;
      }

      if (sendNotification) {
        NotificationService().showSupplierReminderNotification(
          supplierName: supplier.name,
          amount: amount,
          description: 'Payment due',
        );
      }
    } catch (e) {
      success = false;
    }

    return success;
  }

  /// Get overdue customers
  static List<CustomerModel> getOverdueCustomers(
    List<CustomerModel> customers,
    List<TransactionModel> transactions,
  ) {
    final overdueCustomers = <CustomerModel>[];
    final now = DateTime.now();

    for (final customer in customers) {
      final customerTransactions =
          transactions.where((t) => t.customerId == customer.id).toList();

      double balance = 0;
      DateTime? lastDueDate;

      for (final transaction in customerTransactions) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }

        // Assuming due date is 30 days from transaction date
        final dueDate = transaction.date.add(const Duration(days: 30));
        if (lastDueDate == null || dueDate.isAfter(lastDueDate)) {
          lastDueDate = dueDate;
        }
      }

      if (balance > 0 && lastDueDate != null && lastDueDate.isBefore(now)) {
        overdueCustomers.add(customer);
      }
    }

    return overdueCustomers;
  }

  /// Get customers with payments due soon
  static List<CustomerModel> getCustomersWithPaymentsDueSoon(
    List<CustomerModel> customers,
    List<TransactionModel> transactions, {
    int daysAhead = 7,
  }) {
    final dueSoonCustomers = <CustomerModel>[];
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));

    for (final customer in customers) {
      final customerTransactions =
          transactions.where((t) => t.customerId == customer.id).toList();

      double balance = 0;
      DateTime? nextDueDate;

      for (final transaction in customerTransactions) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }

        // Assuming due date is 30 days from transaction date
        final dueDate = transaction.date.add(const Duration(days: 30));
        if (nextDueDate == null || dueDate.isBefore(nextDueDate)) {
          nextDueDate = dueDate;
        }
      }

      if (balance > 0 &&
          nextDueDate != null &&
          nextDueDate.isAfter(now) &&
          nextDueDate.isBefore(futureDate)) {
        dueSoonCustomers.add(customer);
      }
    }

    return dueSoonCustomers;
  }

  /// Process reminder when notification is triggered
  static Future<void> processReminder(String reminderId) async {
    try {
      final reminders = await getAllReminders();
      final reminder = reminders.firstWhere((r) => r.id == reminderId);

      if (reminder.type == ReminderType.payment) {
        await _processPaymentReminder(reminder);
      }

      // Handle recurring reminders
      if (reminder.frequency != ReminderFrequency.once) {
        await _scheduleNextRecurrence(reminder);
      }
    } catch (e) {
      // Reminder not found or error processing
    }
  }

  /// Process payment reminder
  static Future<void> _processPaymentReminder(ReminderModel reminder) async {
    final data = reminder.data;

    if (data.containsKey('customerId')) {
      // Customer payment reminder
      final customer = CustomerModel(
        id: data['customerId'],
        businessId: '',
        userId: '', // This would need to be properly set
        name: data['customerName'],
        phone: data['customerPhone'],
        balance: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (data['sendWhatsApp'] == true) {
        await WhatsAppService.sendPaymentReminderWithDetails(
          phoneNumber: customer.phone ?? '',
          customerName: customer.name,
          amount: data['amount'],
          invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
          dueDate:
              data['dueDate'] != null
                  ? DateTime.parse(data['dueDate'])
                  : DateTime.now().add(const Duration(days: 7)),
        );
      }
    } else if (data.containsKey('supplierId')) {
      // Supplier payment reminder
      final supplier = SupplierModel(
        id: data['supplierId'],
        businessId: '',
        userId: '', // This would need to be properly set
        name: data['supplierName'],
        phone: data['supplierPhone'],
        balance: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (data['sendWhatsApp'] == true) {
        await WhatsAppService.sendPaymentRequest(
          phoneNumber: supplier.phone ?? '',
          customerName: supplier.name,
          amount: data['amount'],
          description: 'Payment due for services',
        );
      }
    }
  }

  /// Schedule next recurrence for recurring reminders
  static Future<void> _scheduleNextRecurrence(ReminderModel reminder) async {
    DateTime nextTime;

    switch (reminder.frequency) {
      case ReminderFrequency.daily:
        nextTime = reminder.scheduledTime.add(const Duration(days: 1));
        break;
      case ReminderFrequency.weekly:
        nextTime = reminder.scheduledTime.add(const Duration(days: 7));
        break;
      case ReminderFrequency.monthly:
        nextTime = DateTime(
          reminder.scheduledTime.year,
          reminder.scheduledTime.month + 1,
          reminder.scheduledTime.day,
          reminder.scheduledTime.hour,
          reminder.scheduledTime.minute,
        );
        break;
      case ReminderFrequency.once:
        return; // No recurrence
    }

    final nextReminder = ReminderModel(
      id: '${reminder.id}_${nextTime.millisecondsSinceEpoch}',
      title: reminder.title,
      description: reminder.description,
      scheduledTime: nextTime,
      type: reminder.type,
      frequency: reminder.frequency,
      data: reminder.data,
      createdAt: reminder.createdAt,
    );

    await _saveReminder(nextReminder);
    await _scheduleNotificationForReminder(nextReminder);
  }
}
