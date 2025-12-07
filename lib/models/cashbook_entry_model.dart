enum CashbookType { cashIn, cashOut }

class CashbookEntryModel {
  final String id;
  final String businessId;
  final String userId; // REQUIRED - was missing!
  final CashbookType type;
  final double amount;
  final String paymentMode;
  final String? details;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  CashbookEntryModel({
    required this.id,
    required this.businessId,
    required this.userId, // Now required
    required this.type,
    required this.amount,
    this.paymentMode = 'cash',
    this.details,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashbookEntryModel.fromJson(Map<String, dynamic> json) {
    return CashbookEntryModel(
      id: json['id'],
      businessId: json['business_id'],
      userId: json['user_id'], // Now included
      type: json['type'] == 'IN' ? CashbookType.cashIn : CashbookType.cashOut,
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['payment_mode'] ?? 'cash',
      details: json['details'],
      entryDate: DateTime.parse(json['entry_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'business_id': businessId,
      'user_id': userId, // Now included
      'type': type == CashbookType.cashIn ? 'IN' : 'OUT',
      'amount': amount,
      'payment_mode': paymentMode,
      'details': details,
      'entry_date': entryDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'business_id': businessId,
      'user_id': userId,
      'type': type == CashbookType.cashIn ? 'IN' : 'OUT',
      'amount': amount,
      'payment_mode': paymentMode,
      'details': details,
      'entry_date': entryDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CashbookEntryModel copyWith({
    String? id,
    String? businessId,
    String? userId,
    CashbookType? type,
    double? amount,
    String? paymentMode,
    String? details,
    DateTime? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashbookEntryModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      details: details ?? this.details,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
