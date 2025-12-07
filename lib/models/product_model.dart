class ProductModel {
  final String id;
  final String businessId;
  final String userId; // REQUIRED - was missing!
  final String name;
  final String? description;
  final String? sku;
  final String? barcode;
  final String? category;
  final String unit;
  final double? purchasePrice;
  final double? sellingPrice;
  final int stockQuantity;
  final int minStockLevel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.businessId,
    required this.userId, // Now required
    required this.name,
    this.description,
    this.sku,
    this.barcode,
    this.category,
    this.unit = 'pcs',
    this.purchasePrice,
    this.sellingPrice,
    this.stockQuantity = 0,
    this.minStockLevel = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      businessId: json['business_id'],
      userId: json['user_id'], // Now included
      name: json['name'],
      description: json['description'],
      sku: json['sku'],
      barcode: json['barcode'],
      category: json['category'],
      unit: json['unit'] ?? 'pcs',
      purchasePrice: json['purchase_price']?.toDouble(),
      sellingPrice: json['selling_price']?.toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      minStockLevel: json['min_stock_level'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'business_id': businessId,
      'user_id': userId, // Now included
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'unit': unit,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include ID if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  // Method for creating new products (without ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'business_id': businessId,
      'user_id': userId,
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'unit': unit,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    String? category,
    String? unit,
    double? purchasePrice,
    double? sellingPrice,
    int? stockQuantity,
    int? minStockLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => stockQuantity <= minStockLevel;

  double get profitMargin {
    if (purchasePrice == null || sellingPrice == null || purchasePrice == 0) {
      return 0.0;
    }
    return ((sellingPrice! - purchasePrice!) / purchasePrice!) * 100;
  }
}
