import 'package:json_annotation/json_annotation.dart';

part 'journal_entry.g.dart';

/// Represents a journal entry in double-entry bookkeeping
@JsonSerializable()
class JournalEntry {
  final String id;
  final String businessId;
  final String voucherNumber;
  final VoucherType voucherType;
  final DateTime entryDate;
  final List<JournalLine> lines;
  final String narration;
  final String? referenceNumber;
  final String? referenceType;
  final String? referenceId;
  final EntryStatus status;
  final DateTime? postedAt;
  final String? postedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.businessId,
    required this.voucherNumber,
    required this.voucherType,
    required this.entryDate,
    required this.lines,
    required this.narration,
    this.referenceNumber,
    this.referenceType,
    this.referenceId,
    this.status = EntryStatus.draft,
    this.postedAt,
    this.postedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);

  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);

  /// Check if the entry is balanced (total debits = total credits)
  bool get isBalanced {
    double totalDebits = 0;
    double totalCredits = 0;

    for (var line in lines) {
      if (line.type == DebitCredit.debit) {
        totalDebits += line.amount;
      } else {
        totalCredits += line.amount;
      }
    }

    return (totalDebits - totalCredits).abs() <
        0.01; // Allow for rounding errors
  }

  /// Get total debit amount
  double get totalDebits {
    return lines
        .where((line) => line.type == DebitCredit.debit)
        .fold(0.0, (sum, line) => sum + line.amount);
  }

  /// Get total credit amount
  double get totalCredits {
    return lines
        .where((line) => line.type == DebitCredit.credit)
        .fold(0.0, (sum, line) => sum + line.amount);
  }

  JournalEntry copyWith({
    String? id,
    String? businessId,
    String? voucherNumber,
    VoucherType? voucherType,
    DateTime? entryDate,
    List<JournalLine>? lines,
    String? narration,
    String? referenceNumber,
    String? referenceType,
    String? referenceId,
    EntryStatus? status,
    DateTime? postedAt,
    String? postedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      voucherType: voucherType ?? this.voucherType,
      entryDate: entryDate ?? this.entryDate,
      lines: lines ?? this.lines,
      narration: narration ?? this.narration,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      status: status ?? this.status,
      postedAt: postedAt ?? this.postedAt,
      postedBy: postedBy ?? this.postedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Represents a line in a journal entry
@JsonSerializable()
class JournalLine {
  final String id;
  final String journalEntryId;
  final String accountId;
  final DebitCredit type;
  final double amount;
  final String? costCenterId;
  final Map<String, dynamic>? dimensions;
  final DateTime createdAt;

  JournalLine({
    required this.id,
    required this.journalEntryId,
    required this.accountId,
    required this.type,
    required this.amount,
    this.costCenterId,
    this.dimensions,
    required this.createdAt,
  });

  factory JournalLine.fromJson(Map<String, dynamic> json) =>
      _$JournalLineFromJson(json);

  Map<String, dynamic> toJson() => _$JournalLineToJson(this);
}

enum VoucherType {
  @JsonValue('sales')
  sales,
  @JsonValue('purchase')
  purchase,
  @JsonValue('payment')
  payment,
  @JsonValue('receipt')
  receipt,
  @JsonValue('journal')
  journal,
  @JsonValue('contra')
  contra,
  @JsonValue('debit_note')
  debitNote,
  @JsonValue('credit_note')
  creditNote,
}

enum DebitCredit {
  @JsonValue('debit')
  debit,
  @JsonValue('credit')
  credit,
}

enum EntryStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('posted')
  posted,
  @JsonValue('reversed')
  reversed,
}

/// Request model for creating a journal entry
class CreateJournalEntryRequest {
  final String businessId;
  final VoucherType voucherType;
  final DateTime entryDate;
  final List<JournalLineRequest> lines;
  final String narration;
  final String? referenceNumber;
  final String? referenceType;
  final String? referenceId;

  CreateJournalEntryRequest({
    required this.businessId,
    required this.voucherType,
    required this.entryDate,
    required this.lines,
    required this.narration,
    this.referenceNumber,
    this.referenceType,
    this.referenceId,
  });

  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'voucher_type': voucherType.name,
    'entry_date': entryDate.toIso8601String(),
    'lines': lines.map((line) => line.toJson()).toList(),
    'narration': narration,
    'reference_number': referenceNumber,
    'reference_type': referenceType,
    'reference_id': referenceId,
  };

  /// Validate that the entry is balanced
  bool get isBalanced {
    double totalDebits = 0;
    double totalCredits = 0;

    for (var line in lines) {
      if (line.type == DebitCredit.debit) {
        totalDebits += line.amount;
      } else {
        totalCredits += line.amount;
      }
    }

    return (totalDebits - totalCredits).abs() < 0.01;
  }
}

class JournalLineRequest {
  final String accountId;
  final DebitCredit type;
  final double amount;
  final String? costCenterId;
  final Map<String, dynamic>? dimensions;

  JournalLineRequest({
    required this.accountId,
    required this.type,
    required this.amount,
    this.costCenterId,
    this.dimensions,
  });

  Map<String, dynamic> toJson() => {
    'account_id': accountId,
    'debit_credit': type.name,
    'amount': amount,
    'cost_center_id': costCenterId,
    'dimensions': dimensions,
  };
}
