enum InvoiceStatus { draft, sent, paid, partiallyPaid, overdue, cancelled }

enum InvoiceType { customer, supplier }

class InvoiceModel {
  final String id;
  final String businessId;
  final String? userId;
  final String? customerId;
  final String? supplierId;
  final String invoiceNumber;
  final InvoiceType invoiceType;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final InvoiceStatus status;
  final String? notes;
  final String? termsConditions;
  final String? templateId;
  final bool whatsappSent;
  final DateTime? whatsappSentAt;
  final List<InvoiceItemModel> items;
  final String? transactionId; // NEW: Link to originating transaction
  final List<PaymentRecord> paymentHistory; // NEW: Track all payments
  final String? pdfPath; // NEW: Path to generated PDF
  final DateTime? pdfGeneratedAt; // NEW: When PDF was generated
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceModel({
    required this.id,
    required this.businessId,
    this.userId,
    this.customerId,
    this.supplierId,
    required this.invoiceNumber,
    this.invoiceType = InvoiceType.customer,
    required this.invoiceDate,
    this.dueDate,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.status = InvoiceStatus.draft,
    this.notes,
    this.termsConditions,
    this.templateId,
    this.whatsappSent = false,
    this.whatsappSentAt,
    this.items = const [],
    this.transactionId,
    this.paymentHistory = const [],
    this.pdfPath,
    this.pdfGeneratedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      businessId: json['business_id'],
      customerId: json['customer_id'],
      supplierId: json['supplier_id'],
      invoiceNumber: json['invoice_number'],
      invoiceType: InvoiceType.values.firstWhere(
        (e) => e.name == json['invoice_type'],
        orElse: () => InvoiceType.customer,
      ),
      invoiceDate: DateTime.parse(json['invoice_date']),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: InvoiceStatus.values.firstWhere(
        (e) =>
            e.name == json['status'] ||
            e.name == _convertStatusName(json['status']),
        orElse: () => InvoiceStatus.draft,
      ),
      notes: json['notes'],
      termsConditions: json['terms_conditions'],
      templateId: json['template_id'],
      whatsappSent: json['whatsapp_sent'] ?? false,
      whatsappSentAt:
          json['whatsapp_sent_at'] != null
              ? DateTime.parse(json['whatsapp_sent_at'])
              : null,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItemModel.fromJson(item))
              .toList() ??
          [],
      transactionId: json['transaction_id'],
      paymentHistory:
          (json['payment_history'] as List<dynamic>?)
              ?.map((payment) => PaymentRecord.fromJson(payment))
              .toList() ??
          [],
      pdfPath: json['pdf_path'],
      pdfGeneratedAt:
          json['pdf_generated_at'] != null
              ? DateTime.parse(json['pdf_generated_at'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static String _convertStatusName(String? status) {
    if (status == 'partially_paid') return 'partiallyPaid';
    return status ?? 'draft';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_id': customerId,
      'supplier_id': supplierId,
      'invoice_number': invoiceNumber,
      'invoice_type': invoiceType.name,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0],
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'status': _statusToString(status),
      'notes': notes,
      'terms_conditions': termsConditions,
      'template_id': templateId,
      'whatsapp_sent': whatsappSent,
      'whatsapp_sent_at': whatsappSentAt?.toIso8601String(),
      'transaction_id': transactionId,
      'pdf_path': pdfPath,
      'pdf_generated_at': pdfGeneratedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String _statusToString(InvoiceStatus status) {
    if (status == InvoiceStatus.partiallyPaid) return 'partially_paid';
    return status.name;
  }

  double get outstandingAmount => totalAmount - paidAmount;

  double get remainingAmount => totalAmount - paidAmount;

  bool get isOverdue =>
      dueDate != null &&
      DateTime.now().isAfter(dueDate!) &&
      outstandingAmount > 0;

  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate!).inDays : 0;

  int get daysUntilDue =>
      dueDate != null ? dueDate!.difference(DateTime.now()).inDays : 0;

  // NEW: Computed properties for payment status checks
  bool get isPartiallyPaid => paidAmount > 0 && paidAmount < totalAmount;

  bool get isFullyPaid => paidAmount >= totalAmount && totalAmount > 0;

  bool get isUnpaid => paidAmount == 0;

  bool get hasTransaction => transactionId != null && transactionId!.isNotEmpty;

  bool get hasPdf => pdfPath != null && pdfPath!.isNotEmpty;

  InvoiceModel copyWith({
    String? id,
    String? businessId,
    String? customerId,
    String? supplierId,
    String? invoiceNumber,
    InvoiceType? invoiceType,
    DateTime? invoiceDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    InvoiceStatus? status,
    String? notes,
    String? termsConditions,
    String? templateId,
    bool? whatsappSent,
    DateTime? whatsappSentAt,
    List<InvoiceItemModel>? items,
    String? transactionId,
    List<PaymentRecord>? paymentHistory,
    String? pdfPath,
    DateTime? pdfGeneratedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceType: invoiceType ?? this.invoiceType,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      termsConditions: termsConditions ?? this.termsConditions,
      templateId: templateId ?? this.templateId,
      whatsappSent: whatsappSent ?? this.whatsappSent,
      whatsappSentAt: whatsappSentAt ?? this.whatsappSentAt,
      items: items ?? this.items,
      transactionId: transactionId ?? this.transactionId,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      pdfPath: pdfPath ?? this.pdfPath,
      pdfGeneratedAt: pdfGeneratedAt ?? this.pdfGeneratedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InvoiceItemModel {
  final String id;
  final String invoiceId;
  final String name;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double discountRate;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceItemModel({
    required this.id,
    required this.invoiceId,
    required this.name,
    this.description,
    this.quantity = 1.0,
    required this.unitPrice,
    this.taxRate = 0.0,
    this.discountRate = 0.0,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      invoiceId: json['invoice_id'],
      name: json['name'],
      description: json['description'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      discountRate: (json['discount_rate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'discount_rate': discountRate,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (taxRate / 100);
  double get discountAmount => subtotal * (discountRate / 100);
  double get calculatedTotal => subtotal + taxAmount - discountAmount;

  InvoiceItemModel copyWith({
    String? id,
    String? invoiceId,
    String? name,
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
    double? discountRate,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      discountRate: discountRate ?? this.discountRate,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Payment Record for tracking payment history within invoices
class PaymentRecord {
  final String id;
  final String invoiceId;
  final double amount;
  final String paymentMode;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;

  PaymentRecord({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.reference,
    this.notes,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'],
      invoiceId: json['invoice_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['payment_mode'],
      paymentDate: DateTime.parse(json['payment_date']),
      reference: json['reference'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_mode': paymentMode,
      'payment_date': paymentDate.toIso8601String(),
      'reference': reference,
      'notes': notes,
    };
  }

  PaymentRecord copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    String? paymentMode,
    DateTime? paymentDate,
    String? reference,
    String? notes,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentDate: paymentDate ?? this.paymentDate,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
    );
  }
}
