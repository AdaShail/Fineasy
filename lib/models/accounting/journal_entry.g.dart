// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) => JournalEntry(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  voucherNumber: json['voucherNumber'] as String,
  voucherType: $enumDecode(_$VoucherTypeEnumMap, json['voucherType']),
  entryDate: DateTime.parse(json['entryDate'] as String),
  lines:
      (json['lines'] as List<dynamic>)
          .map((e) => JournalLine.fromJson(e as Map<String, dynamic>))
          .toList(),
  narration: json['narration'] as String,
  referenceNumber: json['referenceNumber'] as String?,
  referenceType: json['referenceType'] as String?,
  referenceId: json['referenceId'] as String?,
  status:
      $enumDecodeNullable(_$EntryStatusEnumMap, json['status']) ??
      EntryStatus.draft,
  postedAt:
      json['postedAt'] == null
          ? null
          : DateTime.parse(json['postedAt'] as String),
  postedBy: json['postedBy'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$JournalEntryToJson(JournalEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'voucherNumber': instance.voucherNumber,
      'voucherType': _$VoucherTypeEnumMap[instance.voucherType]!,
      'entryDate': instance.entryDate.toIso8601String(),
      'lines': instance.lines,
      'narration': instance.narration,
      'referenceNumber': instance.referenceNumber,
      'referenceType': instance.referenceType,
      'referenceId': instance.referenceId,
      'status': _$EntryStatusEnumMap[instance.status]!,
      'postedAt': instance.postedAt?.toIso8601String(),
      'postedBy': instance.postedBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$VoucherTypeEnumMap = {
  VoucherType.sales: 'sales',
  VoucherType.purchase: 'purchase',
  VoucherType.payment: 'payment',
  VoucherType.receipt: 'receipt',
  VoucherType.journal: 'journal',
  VoucherType.contra: 'contra',
  VoucherType.debitNote: 'debit_note',
  VoucherType.creditNote: 'credit_note',
};

const _$EntryStatusEnumMap = {
  EntryStatus.draft: 'draft',
  EntryStatus.posted: 'posted',
  EntryStatus.reversed: 'reversed',
};

JournalLine _$JournalLineFromJson(Map<String, dynamic> json) => JournalLine(
  id: json['id'] as String,
  journalEntryId: json['journalEntryId'] as String,
  accountId: json['accountId'] as String,
  type: $enumDecode(_$DebitCreditEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  costCenterId: json['costCenterId'] as String?,
  dimensions: json['dimensions'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$JournalLineToJson(JournalLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'journalEntryId': instance.journalEntryId,
      'accountId': instance.accountId,
      'type': _$DebitCreditEnumMap[instance.type]!,
      'amount': instance.amount,
      'costCenterId': instance.costCenterId,
      'dimensions': instance.dimensions,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DebitCreditEnumMap = {
  DebitCredit.debit: 'debit',
  DebitCredit.credit: 'credit',
};
