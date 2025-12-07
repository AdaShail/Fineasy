import 'package:json_annotation/json_annotation.dart';

part 'recurring_payment_model.g.dart';

/// Frequency of recurring payment
enum RecurringFrequency { daily, weekly, monthly, yearly }

/// Status of recurring payment
enum RecurringPaymentStatus { active, paused, cancelled, completed }

/// Model for recurring payment configuration
@JsonSerializable()
class RecurringPaymentModel {
  final String id;
  @JsonKey(name: 'business_id')
  final String businessId;
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'supplier_id')
  final String? supplierId;

  // Recurring configuration
  final String description;
  final double amount;
  final RecurringFrequency frequency;
  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth; // For monthly: 1-31, null for other frequencies
  @JsonKey(name: 'day_of_week')
  final int? dayOfWeek; // For weekly: 1-7 (Monday-Sunday), null for others

  // Date range
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate; // null means indefinite
  @JsonKey(name: 'max_occurrences')
  final int? maxOccurrences; // null means indefinite

  // Status and tracking
  final RecurringPaymentStatus status;
  @JsonKey(name: 'last_generated_date')
  final DateTime? lastGeneratedDate;
  @JsonKey(name: 'occurrences_generated')
  final int occurrencesGenerated;

  // Invoice/Transaction settings
  @JsonKey(name: 'auto_generate_invoice')
  final bool autoGenerateInvoice;
  @JsonKey(name: 'auto_send_reminder')
  final bool autoSendReminder;
  @JsonKey(name: 'reminder_days_before')
  final int reminderDaysBefore;

  // Metadata
  final String? notes;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  RecurringPaymentModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    this.supplierId,
    required this.description,
    required this.amount,
    required this.frequency,
    this.dayOfMonth,
    this.dayOfWeek,
    required this.startDate,
    this.endDate,
    this.maxOccurrences,
    required this.status,
    this.lastGeneratedDate,
    required this.occurrencesGenerated,
    required this.autoGenerateInvoice,
    required this.autoSendReminder,
    required this.reminderDaysBefore,
    this.notes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecurringPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringPaymentModelToJson(this);

  Map<String, dynamic> toCreateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  RecurringPaymentModel copyWith({
    String? id,
    String? businessId,
    String? customerId,
    String? supplierId,
    String? description,
    double? amount,
    RecurringFrequency? frequency,
    int? dayOfMonth,
    int? dayOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    int? maxOccurrences,
    RecurringPaymentStatus? status,
    DateTime? lastGeneratedDate,
    int? occurrencesGenerated,
    bool? autoGenerateInvoice,
    bool? autoSendReminder,
    int? reminderDaysBefore,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringPaymentModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      status: status ?? this.status,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      occurrencesGenerated: occurrencesGenerated ?? this.occurrencesGenerated,
      autoGenerateInvoice: autoGenerateInvoice ?? this.autoGenerateInvoice,
      autoSendReminder: autoSendReminder ?? this.autoSendReminder,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if recurring payment should generate next occurrence
  bool shouldGenerateNext() {
    if (status != RecurringPaymentStatus.active) return false;

    final now = DateTime.now();

    // Check if start date has passed
    if (now.isBefore(startDate)) return false;

    // Check if end date has passed
    if (endDate != null && now.isAfter(endDate!)) return false;

    // Check if max occurrences reached
    final maxOcc = maxOccurrences;
    if (maxOcc != null && occurrencesGenerated >= maxOcc) {
      return false;
    }

    // Check if next occurrence date has arrived
    if (lastGeneratedDate != null) {
      final nextDate = calculateNextOccurrenceDate(lastGeneratedDate!);
      return now.isAfter(nextDate) || now.isAtSameMomentAs(nextDate);
    }

    // First occurrence
    return true;
  }

  /// Calculate next occurrence date based on frequency
  DateTime calculateNextOccurrenceDate(DateTime fromDate) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return DateTime(fromDate.year, fromDate.month, fromDate.day + 1);

      case RecurringFrequency.weekly:
        return DateTime(fromDate.year, fromDate.month, fromDate.day + 7);

      case RecurringFrequency.monthly:
        if (dayOfMonth != null) {
          // Specific day of month
          var nextMonth = fromDate.month + 1;
          var nextYear = fromDate.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }

          // Handle months with fewer days
          final daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          final targetDay = dayOfMonth ?? fromDate.day;
          final day = targetDay > daysInMonth ? daysInMonth : targetDay;

          return DateTime(nextYear, nextMonth, day);
        } else {
          // Same day next month
          var nextMonth = fromDate.month + 1;
          var nextYear = fromDate.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          return DateTime(nextYear, nextMonth, fromDate.day);
        }

      case RecurringFrequency.yearly:
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
    }
  }

  /// Get human-readable frequency description
  String get frequencyDescription {
    switch (frequency) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        if (dayOfWeek != null) {
          final days = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ];
          return 'Every ${days[dayOfWeek! - 1]}';
        }
        return 'Weekly';
      case RecurringFrequency.monthly:
        if (dayOfMonth != null) {
          return 'Monthly on day $dayOfMonth';
        }
        return 'Monthly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }

  /// Check if recurring payment is active
  bool get isActive => status == RecurringPaymentStatus.active;

  /// Check if recurring payment has ended
  bool get hasEnded {
    if (status == RecurringPaymentStatus.completed ||
        status == RecurringPaymentStatus.cancelled) {
      return true;
    }

    if (endDate != null && DateTime.now().isAfter(endDate!)) {
      return true;
    }

    final maxOcc = maxOccurrences;
    if (maxOcc != null && occurrencesGenerated >= maxOcc) {
      return true;
    }

    return false;
  }
}

/// Model for generated occurrence from recurring payment
@JsonSerializable()
class RecurringPaymentOccurrence {
  final String id;
  @JsonKey(name: 'recurring_payment_id')
  final String recurringPaymentId;
  @JsonKey(name: 'business_id')
  final String businessId;
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'supplier_id')
  final String? supplierId;

  @JsonKey(name: 'invoice_id')
  final String? invoiceId;
  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  final double amount;
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  @JsonKey(name: 'generated_at')
  final DateTime generatedAt;

  @JsonKey(name: 'invoice_generated')
  final bool invoiceGenerated;
  @JsonKey(name: 'reminder_sent')
  final bool reminderSent;
  final bool paid;
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  RecurringPaymentOccurrence({
    required this.id,
    required this.recurringPaymentId,
    required this.businessId,
    required this.customerId,
    this.supplierId,
    this.invoiceId,
    this.transactionId,
    required this.amount,
    required this.dueDate,
    required this.generatedAt,
    required this.invoiceGenerated,
    required this.reminderSent,
    required this.paid,
    this.paidAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecurringPaymentOccurrence.fromJson(Map<String, dynamic> json) =>
      _$RecurringPaymentOccurrenceFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringPaymentOccurrenceToJson(this);

  RecurringPaymentOccurrence copyWith({
    String? id,
    String? recurringPaymentId,
    String? businessId,
    String? customerId,
    String? supplierId,
    String? invoiceId,
    String? transactionId,
    double? amount,
    DateTime? dueDate,
    DateTime? generatedAt,
    bool? invoiceGenerated,
    bool? reminderSent,
    bool? paid,
    DateTime? paidAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringPaymentOccurrence(
      id: id ?? this.id,
      recurringPaymentId: recurringPaymentId ?? this.recurringPaymentId,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      invoiceId: invoiceId ?? this.invoiceId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      generatedAt: generatedAt ?? this.generatedAt,
      invoiceGenerated: invoiceGenerated ?? this.invoiceGenerated,
      reminderSent: reminderSent ?? this.reminderSent,
      paid: paid ?? this.paid,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
