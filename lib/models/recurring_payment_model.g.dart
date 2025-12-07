// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringPaymentModel _$RecurringPaymentModelFromJson(
  Map<String, dynamic> json,
) => RecurringPaymentModel(
  id: json['id'] as String,
  businessId: json['business_id'] as String,
  customerId: json['customer_id'] as String,
  supplierId: json['supplier_id'] as String?,
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  frequency: $enumDecode(_$RecurringFrequencyEnumMap, json['frequency']),
  dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
  dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
  startDate: DateTime.parse(json['start_date'] as String),
  endDate:
      json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
  maxOccurrences: (json['max_occurrences'] as num?)?.toInt(),
  status: $enumDecode(_$RecurringPaymentStatusEnumMap, json['status']),
  lastGeneratedDate:
      json['last_generated_date'] == null
          ? null
          : DateTime.parse(json['last_generated_date'] as String),
  occurrencesGenerated: (json['occurrences_generated'] as num).toInt(),
  autoGenerateInvoice: json['auto_generate_invoice'] as bool,
  autoSendReminder: json['auto_send_reminder'] as bool,
  reminderDaysBefore: (json['reminder_days_before'] as num).toInt(),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RecurringPaymentModelToJson(
  RecurringPaymentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'business_id': instance.businessId,
  'customer_id': instance.customerId,
  'supplier_id': instance.supplierId,
  'description': instance.description,
  'amount': instance.amount,
  'frequency': _$RecurringFrequencyEnumMap[instance.frequency]!,
  'day_of_month': instance.dayOfMonth,
  'day_of_week': instance.dayOfWeek,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'max_occurrences': instance.maxOccurrences,
  'status': _$RecurringPaymentStatusEnumMap[instance.status]!,
  'last_generated_date': instance.lastGeneratedDate?.toIso8601String(),
  'occurrences_generated': instance.occurrencesGenerated,
  'auto_generate_invoice': instance.autoGenerateInvoice,
  'auto_send_reminder': instance.autoSendReminder,
  'reminder_days_before': instance.reminderDaysBefore,
  'notes': instance.notes,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$RecurringFrequencyEnumMap = {
  RecurringFrequency.daily: 'daily',
  RecurringFrequency.weekly: 'weekly',
  RecurringFrequency.monthly: 'monthly',
  RecurringFrequency.yearly: 'yearly',
};

const _$RecurringPaymentStatusEnumMap = {
  RecurringPaymentStatus.active: 'active',
  RecurringPaymentStatus.paused: 'paused',
  RecurringPaymentStatus.cancelled: 'cancelled',
  RecurringPaymentStatus.completed: 'completed',
};

RecurringPaymentOccurrence _$RecurringPaymentOccurrenceFromJson(
  Map<String, dynamic> json,
) => RecurringPaymentOccurrence(
  id: json['id'] as String,
  recurringPaymentId: json['recurring_payment_id'] as String,
  businessId: json['business_id'] as String,
  customerId: json['customer_id'] as String,
  supplierId: json['supplier_id'] as String?,
  invoiceId: json['invoice_id'] as String?,
  transactionId: json['transaction_id'] as String?,
  amount: (json['amount'] as num).toDouble(),
  dueDate: DateTime.parse(json['due_date'] as String),
  generatedAt: DateTime.parse(json['generated_at'] as String),
  invoiceGenerated: json['invoice_generated'] as bool,
  reminderSent: json['reminder_sent'] as bool,
  paid: json['paid'] as bool,
  paidAt:
      json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RecurringPaymentOccurrenceToJson(
  RecurringPaymentOccurrence instance,
) => <String, dynamic>{
  'id': instance.id,
  'recurring_payment_id': instance.recurringPaymentId,
  'business_id': instance.businessId,
  'customer_id': instance.customerId,
  'supplier_id': instance.supplierId,
  'invoice_id': instance.invoiceId,
  'transaction_id': instance.transactionId,
  'amount': instance.amount,
  'due_date': instance.dueDate.toIso8601String(),
  'generated_at': instance.generatedAt.toIso8601String(),
  'invoice_generated': instance.invoiceGenerated,
  'reminder_sent': instance.reminderSent,
  'paid': instance.paid,
  'paid_at': instance.paidAt?.toIso8601String(),
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
