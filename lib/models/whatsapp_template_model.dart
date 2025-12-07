enum WhatsAppTemplateType {
  invoiceShare,
  paymentReminder,
  overdueNotice,
  paymentReceived,
  custom,
}

class WhatsAppTemplateModel {
  final String id;
  final String businessId;
  final String name;
  final WhatsAppTemplateType templateType;
  final String messageTemplate;
  final List<String> variables;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  WhatsAppTemplateModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.templateType,
    required this.messageTemplate,
    this.variables = const [],
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WhatsAppTemplateModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppTemplateModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      templateType: _parseTemplateType(json['template_type']),
      messageTemplate: json['message_template'],
      variables:
          (json['variables'] as List<dynamic>?)
              ?.map((v) => v.toString())
              .toList() ??
          [],
      isActive: json['is_active'] ?? true,
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static WhatsAppTemplateType _parseTemplateType(String type) {
    switch (type) {
      case 'invoice_share':
        return WhatsAppTemplateType.invoiceShare;
      case 'payment_reminder':
        return WhatsAppTemplateType.paymentReminder;
      case 'overdue_notice':
        return WhatsAppTemplateType.overdueNotice;
      case 'payment_received':
        return WhatsAppTemplateType.paymentReceived;
      case 'custom':
        return WhatsAppTemplateType.custom;
      default:
        return WhatsAppTemplateType.custom;
    }
  }

  String get templateTypeString {
    switch (templateType) {
      case WhatsAppTemplateType.invoiceShare:
        return 'invoice_share';
      case WhatsAppTemplateType.paymentReminder:
        return 'payment_reminder';
      case WhatsAppTemplateType.overdueNotice:
        return 'overdue_notice';
      case WhatsAppTemplateType.paymentReceived:
        return 'payment_received';
      case WhatsAppTemplateType.custom:
        return 'custom';
    }
  }

  String get displayName {
    switch (templateType) {
      case WhatsAppTemplateType.invoiceShare:
        return 'Invoice Share';
      case WhatsAppTemplateType.paymentReminder:
        return 'Payment Reminder';
      case WhatsAppTemplateType.overdueNotice:
        return 'Overdue Notice';
      case WhatsAppTemplateType.paymentReceived:
        return 'Payment Received';
      case WhatsAppTemplateType.custom:
        return 'Custom Template';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'template_type': templateTypeString,
      'message_template': messageTemplate,
      'variables': variables,
      'is_active': isActive,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Replace template variables with actual values
  String generateMessage(Map<String, String> values) {
    String message = messageTemplate;

    for (final variable in variables) {
      final value = values[variable] ?? '';
      message = message.replaceAll('{{$variable}}', value);
    }

    return message;
  }

  /// Extract variables from template text
  static List<String> extractVariables(String template) {
    final regex = RegExp(r'\{\{([^}]+)\}\}');
    final matches = regex.allMatches(template);
    return matches.map((match) => match.group(1)!.trim()).toSet().toList();
  }

  WhatsAppTemplateModel copyWith({
    String? id,
    String? businessId,
    String? name,
    WhatsAppTemplateType? templateType,
    String? messageTemplate,
    List<String>? variables,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WhatsAppTemplateModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      templateType: templateType ?? this.templateType,
      messageTemplate: messageTemplate ?? this.messageTemplate,
      variables: variables ?? this.variables,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WhatsAppMessageModel {
  final String id;
  final String businessId;
  final String? invoiceId;
  final String? customerId;
  final String? supplierId;
  final String? templateId;
  final WhatsAppTemplateType messageType;
  final String recipientPhone;
  final String recipientName;
  final String messageContent;
  final DateTime sentAt;
  final String deliveryStatus;
  final String? errorMessage;
  final DateTime createdAt;

  WhatsAppMessageModel({
    required this.id,
    required this.businessId,
    this.invoiceId,
    this.customerId,
    this.supplierId,
    this.templateId,
    required this.messageType,
    required this.recipientPhone,
    required this.recipientName,
    required this.messageContent,
    required this.sentAt,
    this.deliveryStatus = 'sent',
    this.errorMessage,
    required this.createdAt,
  });

  factory WhatsAppMessageModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppMessageModel(
      id: json['id'],
      businessId: json['business_id'],
      invoiceId: json['invoice_id'],
      customerId: json['customer_id'],
      supplierId: json['supplier_id'],
      templateId: json['template_id'],
      messageType: WhatsAppTemplateModel._parseTemplateType(
        json['message_type'],
      ),
      recipientPhone: json['recipient_phone'],
      recipientName: json['recipient_name'],
      messageContent: json['message_content'],
      sentAt: DateTime.parse(json['sent_at']),
      deliveryStatus: json['delivery_status'] ?? 'sent',
      errorMessage: json['error_message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'invoice_id': invoiceId,
      'customer_id': customerId,
      'supplier_id': supplierId,
      'template_id': templateId,
      'message_type':
          WhatsAppTemplateModel._parseTemplateType(
            messageType.toString().split('.').last,
          ).toString(),
      'recipient_phone': recipientPhone,
      'recipient_name': recipientName,
      'message_content': messageContent,
      'sent_at': sentAt.toIso8601String(),
      'delivery_status': deliveryStatus,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
