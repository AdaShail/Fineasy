enum InvoiceStatus { draft, sent, paid, partiallyPaid, overdue, cancelled }

enum InvoiceType { customer, supplier }

enum TemplateType { standard, gst, service, product }

/// Invoice Template Configuration
class InvoiceTemplateModel {
  final String id;
  final String businessId;
  final String name;
  final TemplateType templateType;
  final String? headerText;
  final String? footerText;
  final String? logoUrl;
  final Map<String, String> colorScheme;
  final Map<String, dynamic> fieldsConfig;
  final Map<String, dynamic> layoutConfig;
  final List<Map<String, dynamic>> itemColumns;
  final Map<String, dynamic> groupSettings;
  final Map<String, dynamic> paymentTermsConfig;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceTemplateModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.templateType = TemplateType.standard,
    this.headerText,
    this.footerText,
    this.logoUrl,
    this.colorScheme = const {
      'primary': '#2196F3',
      'secondary': '#FFC107',
      'text': '#333333',
    },
    this.fieldsConfig = const {},
    this.layoutConfig = const {
      'showItemDueDates': true,
      'showItemGroups': true,
      'showItemNotes': true,
      'showSKU': false,
      'showHSN': false,
      'showUnit': true,
      'itemsPerPage': 10,
      'groupStyle': 'card',
      'itemStyle': 'row',
    },
    this.itemColumns = const [],
    this.groupSettings = const {
      'showGroupSubtotals': true,
      'showGroupDueDates': true,
      'collapsibleGroups': true,
      'defaultCollapsed': false,
    },
    this.paymentTermsConfig = const {
      'defaultDueDays': 30,
      'allowPartialPayments': true,
      'allowItemLevelPayments': false,
      'showPaymentSchedule': true,
    },
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceTemplateModel.fromJson(Map<String, dynamic> json) {
    return InvoiceTemplateModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      templateType: TemplateType.values.firstWhere(
        (e) => e.name == json['template_type'],
        orElse: () => TemplateType.standard,
      ),
      headerText: json['header_text'],
      footerText: json['footer_text'],
      logoUrl: json['logo_url'],
      colorScheme: json['color_scheme'] != null
          ? Map<String, String>.from(json['color_scheme'])
          : const {'primary': '#2196F3', 'secondary': '#FFC107', 'text': '#333333'},
      fieldsConfig: json['fields_config'] != null
          ? Map<String, dynamic>.from(json['fields_config'])
          : const {},
      layoutConfig: json['layout_config'] != null
          ? Map<String, dynamic>.from(json['layout_config'])
          : const {},
      itemColumns: json['item_columns'] != null
          ? List<Map<String, dynamic>>.from(
              (json['item_columns'] as List).map((e) => Map<String, dynamic>.from(e)))
          : const [],
      groupSettings: json['group_settings'] != null
          ? Map<String, dynamic>.from(json['group_settings'])
          : const {},
      paymentTermsConfig: json['payment_terms_config'] != null
          ? Map<String, dynamic>.from(json['payment_terms_config'])
          : const {},
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'template_type': templateType.name,
      'header_text': headerText,
      'footer_text': footerText,
      'logo_url': logoUrl,
      'color_scheme': colorScheme,
      'fields_config': fieldsConfig,
      'layout_config': layoutConfig,
      'item_columns': itemColumns,
      'group_settings': groupSettings,
      'payment_terms_config': paymentTermsConfig,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters for layout config
  bool get showItemDueDates => layoutConfig['showItemDueDates'] ?? true;
  bool get showItemGroups => layoutConfig['showItemGroups'] ?? true;
  bool get showItemNotes => layoutConfig['showItemNotes'] ?? true;
  bool get showSKU => layoutConfig['showSKU'] ?? false;
  bool get showHSN => layoutConfig['showHSN'] ?? false;
  bool get showUnit => layoutConfig['showUnit'] ?? true;
  int get itemsPerPage => layoutConfig['itemsPerPage'] ?? 10;
  String get groupStyle => layoutConfig['groupStyle'] ?? 'card';
  String get itemStyle => layoutConfig['itemStyle'] ?? 'row';

  // Helper getters for group settings
  bool get showGroupSubtotals => groupSettings['showGroupSubtotals'] ?? true;
  bool get showGroupDueDates => groupSettings['showGroupDueDates'] ?? true;
  bool get collapsibleGroups => groupSettings['collapsibleGroups'] ?? true;
  bool get defaultCollapsed => groupSettings['defaultCollapsed'] ?? false;

  // Helper getters for payment terms
  int get defaultDueDays => paymentTermsConfig['defaultDueDays'] ?? 30;
  bool get allowPartialPayments => paymentTermsConfig['allowPartialPayments'] ?? true;
  bool get allowItemLevelPayments => paymentTermsConfig['allowItemLevelPayments'] ?? false;
  bool get showPaymentSchedule => paymentTermsConfig['showPaymentSchedule'] ?? true;

  InvoiceTemplateModel copyWith({
    String? id,
    String? businessId,
    String? name,
    TemplateType? templateType,
    String? headerText,
    String? footerText,
    String? logoUrl,
    Map<String, String>? colorScheme,
    Map<String, dynamic>? fieldsConfig,
    Map<String, dynamic>? layoutConfig,
    List<Map<String, dynamic>>? itemColumns,
    Map<String, dynamic>? groupSettings,
    Map<String, dynamic>? paymentTermsConfig,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceTemplateModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      templateType: templateType ?? this.templateType,
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      logoUrl: logoUrl ?? this.logoUrl,
      colorScheme: colorScheme ?? this.colorScheme,
      fieldsConfig: fieldsConfig ?? this.fieldsConfig,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      itemColumns: itemColumns ?? this.itemColumns,
      groupSettings: groupSettings ?? this.groupSettings,
      paymentTermsConfig: paymentTermsConfig ?? this.paymentTermsConfig,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

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
  final List<InvoiceItemGroup> itemGroups;
  final String? transactionId;
  final List<PaymentRecord> paymentHistory;
  final String? pdfPath;
  final DateTime? pdfGeneratedAt;
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
    this.itemGroups = const [],
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
      itemGroups:
          (json['item_groups'] as List<dynamic>?)
              ?.map((group) => InvoiceItemGroup.fromJson(group))
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
    List<InvoiceItemGroup>? itemGroups,
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
      itemGroups: itemGroups ?? this.itemGroups,
      transactionId: transactionId ?? this.transactionId,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      pdfPath: pdfPath ?? this.pdfPath,
      pdfGeneratedAt: pdfGeneratedAt ?? this.pdfGeneratedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for grouped items
  List<InvoiceItemModel> get ungroupedItems => 
      items.where((item) => item.groupId == null).toList();

  List<InvoiceItemModel> getItemsForGroup(String groupId) =>
      items.where((item) => item.groupId == groupId).toList();

  Map<String, List<InvoiceItemModel>> get itemsByGroup {
    final Map<String, List<InvoiceItemModel>> grouped = {};
    for (final item in items) {
      final key = item.groupId ?? 'ungrouped';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  List<DateTime> get allDueDates {
    final dates = <DateTime>{};
    if (dueDate != null) dates.add(dueDate!);
    for (final group in itemGroups) {
      if (group.dueDate != null) dates.add(group.dueDate!);
    }
    for (final item in items) {
      if (item.dueDate != null) dates.add(item.dueDate!);
    }
    return dates.toList()..sort();
  }

  DateTime? get earliestDueDate => allDueDates.isNotEmpty ? allDueDates.first : null;
  DateTime? get latestDueDate => allDueDates.isNotEmpty ? allDueDates.last : null;

  List<InvoiceItemModel> get overdueItems =>
      items.where((item) => item.isOverdue).toList();

  double get totalOverdueAmount =>
      overdueItems.fold(0.0, (sum, item) => sum + item.outstandingAmount);
}

/// Status for individual invoice items
enum InvoiceItemStatus { pending, partial, paid, cancelled }

/// Type of tax/discount calculation
enum CalculationType { percentage, fixed }

/// Invoice Item Group for organizing items
class InvoiceItemGroup {
  final String id;
  final String invoiceId;
  final String name;
  final String? description;
  final DateTime? dueDate;
  final int sortOrder;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final bool isCollapsed;
  final String? colorCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceItemModel> items;

  InvoiceItemGroup({
    required this.id,
    required this.invoiceId,
    required this.name,
    this.description,
    this.dueDate,
    this.sortOrder = 0,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.isCollapsed = false,
    this.colorCode,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  factory InvoiceItemGroup.fromJson(Map<String, dynamic> json) {
    return InvoiceItemGroup(
      id: json['id'],
      invoiceId: json['invoice_id'],
      name: json['name'],
      description: json['description'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      sortOrder: json['sort_order'] ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      isCollapsed: json['is_collapsed'] ?? false,
      colorCode: json['color_code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => InvoiceItemModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'name': name,
      'description': description,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'sort_order': sortOrder,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'is_collapsed': isCollapsed,
      'color_code': colorCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);
  int get daysUntilDue => dueDate != null ? dueDate!.difference(DateTime.now()).inDays : 0;
  double get outstandingAmount => items.fold(0.0, (sum, item) => sum + item.outstandingAmount);

  InvoiceItemGroup copyWith({
    String? id,
    String? invoiceId,
    String? name,
    String? description,
    DateTime? dueDate,
    int? sortOrder,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    bool? isCollapsed,
    String? colorCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InvoiceItemModel>? items,
  }) {
    return InvoiceItemGroup(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      sortOrder: sortOrder ?? this.sortOrder,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      colorCode: colorCode ?? this.colorCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class InvoiceItemModel {
  final String id;
  final String invoiceId;
  final String? groupId;
  final String name;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double discountRate;
  final double totalAmount;
  final DateTime? dueDate;
  final int sortOrder;
  final String unit;
  final String? sku;
  final String? hsnCode;
  final String? notes;
  final bool isTaxable;
  final CalculationType taxType;
  final CalculationType discountType;
  final InvoiceItemStatus status;
  final double paidAmount;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceItemModel({
    required this.id,
    required this.invoiceId,
    this.groupId,
    required this.name,
    this.description,
    this.quantity = 1.0,
    required this.unitPrice,
    this.taxRate = 0.0,
    this.discountRate = 0.0,
    required this.totalAmount,
    this.dueDate,
    this.sortOrder = 0,
    this.unit = 'unit',
    this.sku,
    this.hsnCode,
    this.notes,
    this.isTaxable = true,
    this.taxType = CalculationType.percentage,
    this.discountType = CalculationType.percentage,
    this.status = InvoiceItemStatus.pending,
    this.paidAmount = 0.0,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      invoiceId: json['invoice_id'],
      groupId: json['group_id'],
      name: json['name'],
      description: json['description'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      discountRate: (json['discount_rate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      sortOrder: json['sort_order'] ?? 0,
      unit: json['unit'] ?? 'unit',
      sku: json['sku'],
      hsnCode: json['hsn_code'],
      notes: json['notes'],
      isTaxable: json['is_taxable'] ?? true,
      taxType: CalculationType.values.firstWhere(
        (e) => e.name == json['tax_type'],
        orElse: () => CalculationType.percentage,
      ),
      discountType: CalculationType.values.firstWhere(
        (e) => e.name == json['discount_type'],
        orElse: () => CalculationType.percentage,
      ),
      status: InvoiceItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceItemStatus.pending,
      ),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'group_id': groupId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'discount_rate': discountRate,
      'total_amount': totalAmount,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'sort_order': sortOrder,
      'unit': unit,
      'sku': sku,
      'hsn_code': hsnCode,
      'notes': notes,
      'is_taxable': isTaxable,
      'tax_type': taxType.name,
      'discount_type': discountType.name,
      'status': status.name,
      'paid_amount': paidAmount,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get subtotal => quantity * unitPrice;
  
  double get taxAmount {
    if (!isTaxable) return 0.0;
    return taxType == CalculationType.percentage 
        ? subtotal * (taxRate / 100) 
        : taxRate;
  }
  
  double get discountAmount {
    return discountType == CalculationType.percentage 
        ? subtotal * (discountRate / 100) 
        : discountRate;
  }
  
  double get calculatedTotal => subtotal + taxAmount - discountAmount;
  double get outstandingAmount => totalAmount - paidAmount;
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && outstandingAmount > 0;
  bool get isFullyPaid => paidAmount >= totalAmount;
  bool get isPartiallyPaid => paidAmount > 0 && paidAmount < totalAmount;
  int get daysUntilDue => dueDate != null ? dueDate!.difference(DateTime.now()).inDays : 0;

  InvoiceItemModel copyWith({
    String? id,
    String? invoiceId,
    String? groupId,
    String? name,
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
    double? discountRate,
    double? totalAmount,
    DateTime? dueDate,
    int? sortOrder,
    String? unit,
    String? sku,
    String? hsnCode,
    String? notes,
    bool? isTaxable,
    CalculationType? taxType,
    CalculationType? discountType,
    InvoiceItemStatus? status,
    double? paidAmount,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      discountRate: discountRate ?? this.discountRate,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDate: dueDate ?? this.dueDate,
      sortOrder: sortOrder ?? this.sortOrder,
      unit: unit ?? this.unit,
      sku: sku ?? this.sku,
      hsnCode: hsnCode ?? this.hsnCode,
      notes: notes ?? this.notes,
      isTaxable: isTaxable ?? this.isTaxable,
      taxType: taxType ?? this.taxType,
      discountType: discountType ?? this.discountType,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
      metadata: metadata ?? this.metadata,
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
