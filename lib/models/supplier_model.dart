class SupplierModel {
  final String id;
  final String businessId;
  final String userId; // REQUIRED - was missing!
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? upiId;
  final double
  balance; // Positive = we owe supplier, Negative = supplier owes us
  final DateTime? lastTransactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierModel({
    required this.id,
    required this.businessId,
    required this.userId, // Now required
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.upiId,
    this.balance = 0.0,
    this.lastTransactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      businessId: json['business_id'],
      userId: json['user_id'], // Now included
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      gstNumber: json['gst_number'],
      upiId: json['upi_id'],
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      lastTransactionDate:
          json['last_transaction_date'] != null
              ? DateTime.parse(json['last_transaction_date'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'business_id': businessId,
      'user_id': userId, // Now included
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'gst_number': gstNumber,
      'upi_id': upiId,
      'balance': balance,
      'last_transaction_date': lastTransactionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include ID if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  // Method for creating new suppliers (without ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'business_id': businessId,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'gst_number': gstNumber,
      'upi_id': upiId,
      'balance': balance,
      'last_transaction_date': lastTransactionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SupplierModel copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
    String? upiId,
    double? balance,
    DateTime? lastTransactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      upiId: upiId ?? this.upiId,
      balance: balance ?? this.balance,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
