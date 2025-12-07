import 'package:json_annotation/json_annotation.dart';

part 'chart_of_accounts.g.dart';

/// Represents an account in the chart of accounts
@JsonSerializable()
class ChartOfAccounts {
  final String id;
  final String businessId;
  final String code;
  final String name;
  final AccountType type;
  final AccountCategory category;
  final String? parentAccountId;
  final bool isGroup;
  final List<String> childAccountIds;
  final String currency;
  final double openingBalance;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChartOfAccounts({
    required this.id,
    required this.businessId,
    required this.code,
    required this.name,
    required this.type,
    required this.category,
    this.parentAccountId,
    this.isGroup = false,
    this.childAccountIds = const [],
    this.currency = 'INR',
    this.openingBalance = 0.0,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChartOfAccounts.fromJson(Map<String, dynamic> json) =>
      _$ChartOfAccountsFromJson(json);

  Map<String, dynamic> toJson() => _$ChartOfAccountsToJson(this);

  ChartOfAccounts copyWith({
    String? id,
    String? businessId,
    String? code,
    String? name,
    AccountType? type,
    AccountCategory? category,
    String? parentAccountId,
    bool? isGroup,
    List<String>? childAccountIds,
    String? currency,
    double? openingBalance,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChartOfAccounts(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      isGroup: isGroup ?? this.isGroup,
      childAccountIds: childAccountIds ?? this.childAccountIds,
      currency: currency ?? this.currency,
      openingBalance: openingBalance ?? this.openingBalance,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AccountType {
  @JsonValue('asset')
  asset,
  @JsonValue('liability')
  liability,
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
  @JsonValue('equity')
  equity,
}

enum AccountCategory {
  // Assets
  @JsonValue('current_asset')
  currentAsset,
  @JsonValue('fixed_asset')
  fixedAsset,
  @JsonValue('investment')
  investment,

  // Liabilities
  @JsonValue('current_liability')
  currentLiability,
  @JsonValue('long_term_liability')
  longTermLiability,

  // Income
  @JsonValue('direct_income')
  directIncome,
  @JsonValue('indirect_income')
  indirectIncome,

  // Expenses
  @JsonValue('direct_expense')
  directExpense,
  @JsonValue('indirect_expense')
  indirectExpense,

  // Equity
  @JsonValue('capital')
  capital,
  @JsonValue('reserves')
  reserves,
}

/// Request model for creating an account
class CreateAccountRequest {
  final String businessId;
  final String code;
  final String name;
  final AccountType type;
  final AccountCategory category;
  final String? parentAccountId;
  final bool isGroup;
  final String currency;
  final double openingBalance;
  final Map<String, dynamic>? metadata;

  CreateAccountRequest({
    required this.businessId,
    required this.code,
    required this.name,
    required this.type,
    required this.category,
    this.parentAccountId,
    this.isGroup = false,
    this.currency = 'INR',
    this.openingBalance = 0.0,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'code': code,
    'name': name,
    'account_type': type.name,
    'account_category': category.name,
    'parent_account_id': parentAccountId,
    'is_group': isGroup,
    'currency': currency,
    'opening_balance': openingBalance,
    'metadata': metadata,
  };
}
