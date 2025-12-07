enum ExpenseCategory {
  office,
  travel,
  marketing,
  utilities,
  rent,
  supplies,
  maintenance,
  professional,
  other,
}

enum RecurrenceType { daily, weekly, monthly, quarterly, yearly }

class ExpenseModel {
  final String id;
  final String businessId;
  final String userId;
  final String category;
  final double amount;
  final String description;
  final DateTime expenseDate;
  final String? receipt;
  final String? vendor;
  final String? reference;
  final String? notes;
  final bool isRecurring;
  final RecurrenceType? recurrenceType;
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    required this.expenseDate,
    this.receipt,
    this.vendor,
    this.reference,
    this.notes,
    this.isRecurring = false,
    this.recurrenceType,
    this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      businessId: json['business_id'],
      userId: json['user_id'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      expenseDate: DateTime.parse(json['expense_date']),
      receipt: json['receipt'],
      vendor: json['vendor'],
      reference: json['reference'],
      notes: json['notes'],
      isRecurring: json['is_recurring'] ?? false,
      recurrenceType:
          json['recurrence_type'] != null
              ? RecurrenceType.values.firstWhere(
                (e) => e.toString().split('.').last == json['recurrence_type'],
                orElse: () => RecurrenceType.monthly,
              )
              : null,
      nextDueDate:
          json['next_due_date'] != null
              ? DateTime.parse(json['next_due_date'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'business_id': businessId,
      'user_id': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'receipt': receipt,
      'vendor': vendor,
      'reference': reference,
      'notes': notes,
      'is_recurring': isRecurring,
      'recurrence_type': recurrenceType?.toString().split('.').last,
      'next_due_date': nextDueDate?.toIso8601String().split('T')[0],
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
      'category': category,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'receipt': receipt,
      'vendor': vendor,
      'reference': reference,
      'notes': notes,
      'is_recurring': isRecurring,
      'recurrence_type': recurrenceType?.toString().split('.').last,
      'next_due_date': nextDueDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? category,
    double? amount,
    String? description,
    DateTime? expenseDate,
    String? receipt,
    String? vendor,
    String? reference,
    String? notes,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      receipt: receipt ?? this.receipt,
      vendor: vendor ?? this.vendor,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case 'office':
        return 'Office Supplies';
      case 'travel':
        return 'Travel';
      case 'marketing':
        return 'Marketing';
      case 'utilities':
        return 'Utilities';
      case 'rent':
        return 'Rent';
      case 'supplies':
        return 'Supplies';
      case 'maintenance':
        return 'Maintenance';
      case 'professional':
        return 'Professional Services';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }
}
