import 'package:json_annotation/json_annotation.dart';

part 'payment_models.g.dart';

// Payment Reminder Models
@JsonSerializable()
class PaymentReminder {
  final String id;
  final String businessId;
  final String invoiceId;
  final String customerId;
  final double amount;
  final DateTime dueDate;
  final int reminderNumber;
  final String reminderType;
  final bool sent;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? message;
  final String? deliveryMethod;
  final String? status;
  final bool? responseReceived;

  PaymentReminder({
    required this.id,
    required this.businessId,
    required this.invoiceId,
    required this.customerId,
    required this.amount,
    required this.dueDate,
    required this.reminderNumber,
    required this.reminderType,
    required this.sent,
    this.sentAt,
    required this.createdAt,
    this.scheduledDate,
    this.message,
    this.deliveryMethod,
    this.status,
    this.responseReceived,
  });

  factory PaymentReminder.fromJson(Map<String, dynamic> json) =>
      _$PaymentReminderFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentReminderToJson(this);
}

// Expense Control Models
@JsonSerializable()
class ExpenseControlRule {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final String category;
  final double threshold;
  final String action;
  final bool isActive;
  final DateTime createdAt;
  final String? expenseCategory;
  final double? thresholdAmount;
  final String? thresholdType;
  final String? controlAction;
  final String? priorityLevel;

  ExpenseControlRule({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.category,
    required this.threshold,
    required this.action,
    required this.isActive,
    required this.createdAt,
    this.expenseCategory,
    this.thresholdAmount,
    this.thresholdType,
    this.controlAction,
    this.priorityLevel,
  });

  factory ExpenseControlRule.fromJson(Map<String, dynamic> json) =>
      _$ExpenseControlRuleFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseControlRuleToJson(this);
}

@JsonSerializable()
class FundReservation {
  final String id;
  final String businessId;
  final String purpose;
  final double amount;
  final DateTime reservedAt;
  final DateTime? releaseDate;
  final String status;
  final double? reservedAmount;
  final DateTime? reservationDate;
  final String? obligationType;
  final String? obligationId;
  final DateTime? createdAt;

  FundReservation({
    required this.id,
    required this.businessId,
    required this.purpose,
    required this.amount,
    required this.reservedAt,
    this.releaseDate,
    required this.status,
    this.reservedAmount,
    this.reservationDate,
    this.obligationType,
    this.obligationId,
    this.createdAt,
  });

  factory FundReservation.fromJson(Map<String, dynamic> json) =>
      _$FundReservationFromJson(json);
  Map<String, dynamic> toJson() => _$FundReservationToJson(this);
}

// GST Models
@JsonSerializable()
class GSTObligation {
  final String id;
  final String businessId;
  final String period;
  final double gstAmount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime createdAt;
  final String? filingPeriod;
  final double? estimatedAmount;
  final String? status;
  final String? paymentStatus;
  final bool? fundsReserved;
  final DateTime? updatedAt;

  GSTObligation({
    required this.id,
    required this.businessId,
    required this.period,
    required this.gstAmount,
    required this.dueDate,
    required this.isPaid,
    this.paidAt,
    required this.createdAt,
    this.filingPeriod,
    this.estimatedAmount,
    this.status,
    this.paymentStatus,
    this.fundsReserved,
    this.updatedAt,
  });

  factory GSTObligation.fromJson(Map<String, dynamic> json) =>
      _$GSTObligationFromJson(json);
  Map<String, dynamic> toJson() => _$GSTObligationToJson(this);
}
