// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_of_accounts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartOfAccounts _$ChartOfAccountsFromJson(Map<String, dynamic> json) =>
    ChartOfAccounts(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      category: $enumDecode(_$AccountCategoryEnumMap, json['category']),
      parentAccountId: json['parentAccountId'] as String?,
      isGroup: json['isGroup'] as bool? ?? false,
      childAccountIds:
          (json['childAccountIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currency: json['currency'] as String? ?? 'INR',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChartOfAccountsToJson(ChartOfAccounts instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'code': instance.code,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'category': _$AccountCategoryEnumMap[instance.category]!,
      'parentAccountId': instance.parentAccountId,
      'isGroup': instance.isGroup,
      'childAccountIds': instance.childAccountIds,
      'currency': instance.currency,
      'openingBalance': instance.openingBalance,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AccountTypeEnumMap = {
  AccountType.asset: 'asset',
  AccountType.liability: 'liability',
  AccountType.income: 'income',
  AccountType.expense: 'expense',
  AccountType.equity: 'equity',
};

const _$AccountCategoryEnumMap = {
  AccountCategory.currentAsset: 'current_asset',
  AccountCategory.fixedAsset: 'fixed_asset',
  AccountCategory.investment: 'investment',
  AccountCategory.currentLiability: 'current_liability',
  AccountCategory.longTermLiability: 'long_term_liability',
  AccountCategory.directIncome: 'direct_income',
  AccountCategory.indirectIncome: 'indirect_income',
  AccountCategory.directExpense: 'direct_expense',
  AccountCategory.indirectExpense: 'indirect_expense',
  AccountCategory.capital: 'capital',
  AccountCategory.reserves: 'reserves',
};
