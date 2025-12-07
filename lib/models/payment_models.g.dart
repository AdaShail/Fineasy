// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentReminder _$PaymentReminderFromJson(Map<String, dynamic> json) =>
    PaymentReminder(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      invoiceId: json['invoiceId'] as String,
      customerId: json['customerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      reminderNumber: (json['reminderNumber'] as num).toInt(),
      reminderType: json['reminderType'] as String,
      sent: json['sent'] as bool,
      sentAt:
          json['sentAt'] == null
              ? null
              : DateTime.parse(json['sentAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledDate:
          json['scheduledDate'] == null
              ? null
              : DateTime.parse(json['scheduledDate'] as String),
      message: json['message'] as String?,
      deliveryMethod: json['deliveryMethod'] as String?,
      status: json['status'] as String?,
      responseReceived: json['responseReceived'] as bool?,
    );

Map<String, dynamic> _$PaymentReminderToJson(PaymentReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'invoiceId': instance.invoiceId,
      'customerId': instance.customerId,
      'amount': instance.amount,
      'dueDate': instance.dueDate.toIso8601String(),
      'reminderNumber': instance.reminderNumber,
      'reminderType': instance.reminderType,
      'sent': instance.sent,
      'sentAt': instance.sentAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'message': instance.message,
      'deliveryMethod': instance.deliveryMethod,
      'status': instance.status,
      'responseReceived': instance.responseReceived,
    };

ExpenseControlRule _$ExpenseControlRuleFromJson(Map<String, dynamic> json) =>
    ExpenseControlRule(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      threshold: (json['threshold'] as num).toDouble(),
      action: json['action'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expenseCategory: json['expenseCategory'] as String?,
      thresholdAmount: (json['thresholdAmount'] as num?)?.toDouble(),
      thresholdType: json['thresholdType'] as String?,
      controlAction: json['controlAction'] as String?,
      priorityLevel: json['priorityLevel'] as String?,
    );

Map<String, dynamic> _$ExpenseControlRuleToJson(ExpenseControlRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'threshold': instance.threshold,
      'action': instance.action,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'expenseCategory': instance.expenseCategory,
      'thresholdAmount': instance.thresholdAmount,
      'thresholdType': instance.thresholdType,
      'controlAction': instance.controlAction,
      'priorityLevel': instance.priorityLevel,
    };

FundReservation _$FundReservationFromJson(Map<String, dynamic> json) =>
    FundReservation(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      purpose: json['purpose'] as String,
      amount: (json['amount'] as num).toDouble(),
      reservedAt: DateTime.parse(json['reservedAt'] as String),
      releaseDate:
          json['releaseDate'] == null
              ? null
              : DateTime.parse(json['releaseDate'] as String),
      status: json['status'] as String,
      reservedAmount: (json['reservedAmount'] as num?)?.toDouble(),
      reservationDate:
          json['reservationDate'] == null
              ? null
              : DateTime.parse(json['reservationDate'] as String),
      obligationType: json['obligationType'] as String?,
      obligationId: json['obligationId'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FundReservationToJson(FundReservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'purpose': instance.purpose,
      'amount': instance.amount,
      'reservedAt': instance.reservedAt.toIso8601String(),
      'releaseDate': instance.releaseDate?.toIso8601String(),
      'status': instance.status,
      'reservedAmount': instance.reservedAmount,
      'reservationDate': instance.reservationDate?.toIso8601String(),
      'obligationType': instance.obligationType,
      'obligationId': instance.obligationId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

GSTObligation _$GSTObligationFromJson(Map<String, dynamic> json) =>
    GSTObligation(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      period: json['period'] as String,
      gstAmount: (json['gstAmount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      isPaid: json['isPaid'] as bool,
      paidAt:
          json['paidAt'] == null
              ? null
              : DateTime.parse(json['paidAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      filingPeriod: json['filingPeriod'] as String?,
      estimatedAmount: (json['estimatedAmount'] as num?)?.toDouble(),
      status: json['status'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      fundsReserved: json['fundsReserved'] as bool?,
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GSTObligationToJson(GSTObligation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'period': instance.period,
      'gstAmount': instance.gstAmount,
      'dueDate': instance.dueDate.toIso8601String(),
      'isPaid': instance.isPaid,
      'paidAt': instance.paidAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'filingPeriod': instance.filingPeriod,
      'estimatedAmount': instance.estimatedAmount,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'fundsReserved': instance.fundsReserved,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
