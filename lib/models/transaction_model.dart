enum TransactionType {
  income,
  expense,
  credit,
  debit,
  paymentIn,
  paymentOut,
  sale,
  purchase,
}

enum PaymentMode { cash, card, upi, netBanking, cheque, bankTransfer, other }

enum TransactionStatus { pending, completed, cancelled }

class TransactionModel {
  final String id;
  final String businessId;
  final String userId; // REQUIRED - was missing!
  final String? customerId;
  final String? supplierId;
  final TransactionType type;
  final double amount;
  final String description;
  final PaymentMode paymentMode;
  final DateTime date;
  final DateTime? dueDate; // Added missing field
  final String? reference;
  final String? invoiceNumber; // Added missing field
  final String? invoiceId; // NEW: Link to generated invoice
  final String? notes;
  final List<String>? attachments; // Added missing field
  final TransactionStatus status; // Added missing field
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.businessId,
    required this.userId, // Now required
    this.customerId,
    this.supplierId,
    required this.type,
    required this.amount,
    required this.description,
    required this.paymentMode,
    required this.date,
    this.dueDate,
    this.reference,
    this.invoiceNumber,
    this.invoiceId,
    this.notes,
    this.attachments,
    this.status = TransactionStatus.completed,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      businessId: json['business_id'],
      userId: json['user_id'], // Now included
      customerId: json['customer_id'],
      supplierId: json['supplier_id'],
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      paymentMode: _parsePaymentMode(json['payment_mode']),
      date: DateTime.parse(json['date']),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      reference: json['reference'],
      invoiceNumber: json['invoice_number'],
      invoiceId: json['invoice_id'],
      notes: json['notes'],
      attachments:
          json['attachments'] != null
              ? List<String>.from(json['attachments'])
              : null,
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      isSynced: json['is_synced'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'payment_in':
        return TransactionType.paymentIn;
      case 'payment_out':
        return TransactionType.paymentOut;
      default:
        return TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == type,
        );
    }
  }

  static PaymentMode _parsePaymentMode(String mode) {
    switch (mode) {
      case 'bankTransfer':
        return PaymentMode.bankTransfer;
      default:
        return PaymentMode.values.firstWhere(
          (e) => e.toString().split('.').last == mode,
        );
    }
  }

  Map<String, dynamic> toJson() {
    final json = {
      'business_id': businessId,
      'user_id': userId, // Now included
      'customer_id': customerId,
      'supplier_id': supplierId,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'description': description,
      'payment_mode': _paymentModeToString(paymentMode),
      'date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'reference': reference,
      'invoice_number': invoiceNumber,
      'invoice_id': invoiceId,
      'notes': notes,
      'attachments': attachments,
      'status': status.toString().split('.').last,
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include ID if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.paymentIn:
        return 'payment_in';
      case TransactionType.paymentOut:
        return 'payment_out';
      default:
        return type.toString().split('.').last;
    }
  }

  String _paymentModeToString(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.bankTransfer:
        return 'bankTransfer';
      default:
        return mode.toString().split('.').last;
    }
  }

  // Method for creating new transactions (without ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'business_id': businessId,
      'user_id': userId,
      'customer_id': customerId,
      'supplier_id': supplierId,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'description': description,
      'payment_mode': _paymentModeToString(paymentMode),
      'date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'reference': reference,
      'invoice_number': invoiceNumber,
      'invoice_id': invoiceId,
      'notes': notes,
      'attachments': attachments,
      'status': status.toString().split('.').last,
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // NEW: Computed properties for invoice linking
  bool get hasInvoice => invoiceId != null && invoiceId!.isNotEmpty;

  bool get needsInvoice =>
      customerId != null && !hasInvoice && type == TransactionType.sale;

  TransactionModel copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? customerId,
    String? supplierId,
    TransactionType? type,
    double? amount,
    String? description,
    PaymentMode? paymentMode,
    DateTime? date,
    DateTime? dueDate,
    String? reference,
    String? invoiceNumber,
    String? invoiceId,
    String? notes,
    List<String>? attachments,
    TransactionStatus? status,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMode: paymentMode ?? this.paymentMode,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      reference: reference ?? this.reference,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceId: invoiceId ?? this.invoiceId,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
