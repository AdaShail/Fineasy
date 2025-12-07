import '../utils/encryption_mixin.dart';

class BusinessModel with EncryptionMixin {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? address;
  final String? city;
  final String? state;
  final String country;
  final String? pincode;
  final String? gstNumber;
  final String currency;
  final String currencySymbol;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Sensitive fields that should be encrypted at rest
  @override
  List<String> get sensitiveFields => ['gst_number', 'address'];

  BusinessModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.address,
    this.city,
    this.state,
    required this.country,
    this.pincode,
    this.gstNumber,
    this.currency = 'INR',
    this.currencySymbol = '₹',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      category: json['category'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      gstNumber: json['gst_number'],
      currency: json['currency'] ?? 'INR',
      currencySymbol: json['currency_symbol'] ?? '₹',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'user_id': userId,
      'name': name,
      'category': category,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'gst_number': gstNumber,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include ID if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  // Method for creating new business (without ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'name': name,
      'category': category,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'gst_number': gstNumber,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BusinessModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? gstNumber,
    String? currency,
    String? currencySymbol,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      gstNumber: gstNumber ?? this.gstNumber,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
