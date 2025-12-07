import '../models/transaction_model.dart';

enum PaymentStatus { pending, completed, failed, cancelled }

class PaymentModel {
  final String id;
  final String businessId;
  final String userId;
  final String? transactionId;
  final String? invoiceId;
  final String? customerId;
  final String? supplierId;
  final double amount;
  final PaymentMode paymentMode;
  final PaymentStatus status;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.businessId,
    required this.userId,
    this.transactionId,
    this.invoiceId,
    this.customerId,
    this.supplierId,
    required this.amount,
    required this.paymentMode,
    this.status = PaymentStatus.pending,
    required this.paymentDate,
    this.reference,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      businessId: json['business_id'],
      userId: json['user_id'],
      transactionId: json['transaction_id'],
      invoiceId: json['invoice_id'],
      customerId: json['customer_id'],
      supplierId: json['supplier_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.toString().split('.').last == json['payment_mode'],
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: DateTime.parse(json['payment_date']),
      reference: json['reference'],
      notes: json['notes'],
      receiptUrl: json['receipt_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'business_id': businessId,
      'user_id': userId,
      'transaction_id': transactionId,
      'invoice_id': invoiceId,
      'customer_id': customerId,
      'supplier_id': supplierId,
      'amount': amount,
      'payment_mode': paymentMode.toString().split('.').last,
      'status': status.toString().split('.').last,
      'payment_date': paymentDate.toIso8601String(),
      'reference': reference,
      'notes': notes,
      'receipt_url': receiptUrl,
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
      'transaction_id': transactionId,
      'invoice_id': invoiceId,
      'customer_id': customerId,
      'supplier_id': supplierId,
      'amount': amount,
      'payment_mode': paymentMode.toString().split('.').last,
      'status': status.toString().split('.').last,
      'payment_date': paymentDate.toIso8601String(),
      'reference': reference,
      'notes': notes,
      'receipt_url': receiptUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? transactionId,
    String? invoiceId,
    String? customerId,
    String? supplierId,
    double? amount,
    PaymentMode? paymentMode,
    PaymentStatus? status,
    DateTime? paymentDate,
    String? reference,
    String? notes,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      transactionId: transactionId ?? this.transactionId,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
