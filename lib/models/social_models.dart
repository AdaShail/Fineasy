class UserProfile {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? phone;
  final String? email;
  final bool isPublic;
  final double totalCorpus;
  final double monthlyBudget;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.phone,
    this.email,
    this.isPublic = true,
    this.totalCorpus = 0.0,
    this.monthlyBudget = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      bio: json['bio']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      isPublic: json['is_public'] ?? true,
      totalCorpus: (json['total_corpus'] ?? 0.0).toDouble(),
      monthlyBudget: (json['monthly_budget'] ?? 0.0).toDouble(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'phone': phone,
      'email': email,
      'is_public': isPublic,
      'total_corpus': totalCorpus,
      'monthly_budget': monthlyBudget,
    };
  }
}

class UserConnection {
  final String id;
  final String requesterId;
  final String addresseeId;
  final String status;
  final UserProfile? requester;
  final UserProfile? addressee;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserConnection({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    this.requester,
    this.addressee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserConnection.fromJson(Map<String, dynamic> json) {
    return UserConnection(
      id: json['id'] ?? '',
      requesterId: json['requester_id'] ?? '',
      addresseeId: json['addressee_id'] ?? '',
      status: json['status'] ?? 'pending',
      requester:
          json['requester'] != null
              ? UserProfile.fromJson(json['requester'])
              : null,
      addressee:
          json['addressee'] != null
              ? UserProfile.fromJson(json['addressee'])
              : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ExpenseGroup {
  final String id;
  final String name;
  final String? description;
  final String inviteCode;
  final String creatorId;
  final bool isActive;
  final double groupBudget;
  final UserProfile? creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseGroup({
    required this.id,
    required this.name,
    this.description,
    required this.inviteCode,
    required this.creatorId,
    this.isActive = true,
    this.groupBudget = 0.0,
    this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseGroup.fromJson(Map<String, dynamic> json) {
    return ExpenseGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      inviteCode: json['invite_code']?.toString() ?? '',
      creatorId: json['creator_id']?.toString() ?? '',
      isActive: json['is_active'] ?? true,
      groupBudget: (json['group_budget'] ?? 0.0).toDouble(),
      creator:
          json['creator'] != null && json['creator'] is Map<String, dynamic>
              ? UserProfile.fromJson(json['creator'])
              : null,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class Expense {
  final String id;
  final String userId;
  final String? groupId;
  final String title;
  final String? description;
  final double amount;
  final String category;
  final String expenseType;
  final String transactionType;
  final DateTime date;
  final String? receiptUrl;
  final List<String>? tags;
  final bool isRecurring;
  final String? recurringFrequency;
  final UserProfile? user;
  final ExpenseGroup? group;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.userId,
    this.groupId,
    required this.title,
    this.description,
    required this.amount,
    required this.category,
    required this.expenseType,
    required this.transactionType,
    required this.date,
    this.receiptUrl,
    this.tags,
    this.isRecurring = false,
    this.recurringFrequency,
    this.user,
    this.group,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      title: json['title'],
      description: json['description'],
      amount: (json['amount']).toDouble(),
      category: json['category'],
      expenseType: json['expense_type'],
      transactionType: json['transaction_type'],
      date: DateTime.parse(json['date']),
      receiptUrl: json['receipt_url'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isRecurring: json['is_recurring'] ?? false,
      recurringFrequency: json['recurring_frequency'],
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      group:
          json['group'] != null ? ExpenseGroup.fromJson(json['group']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class CorpusTransaction {
  final String id;
  final String userId;
  final String expenseId;
  final double amount;
  final String transactionType;
  final double runningBalance;
  final String? description;
  final Expense? expense;
  final DateTime createdAt;

  CorpusTransaction({
    required this.id,
    required this.userId,
    required this.expenseId,
    required this.amount,
    required this.transactionType,
    required this.runningBalance,
    this.description,
    this.expense,
    required this.createdAt,
  });

  factory CorpusTransaction.fromJson(Map<String, dynamic> json) {
    return CorpusTransaction(
      id: json['id'],
      userId: json['user_id'],
      expenseId: json['expense_id'],
      amount: (json['amount']).toDouble(),
      transactionType: json['transaction_type'],
      runningBalance: (json['running_balance']).toDouble(),
      description: json['description'],
      expense:
          json['expense'] != null ? Expense.fromJson(json['expense']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class FinancialTask {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final double? targetAmount;
  final double currentAmount;
  final DateTime? dueDate;
  final String taskType;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialTask({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.targetAmount,
    this.currentAmount = 0.0,
    this.dueDate,
    required this.taskType,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialTask.fromJson(Map<String, dynamic> json) {
    return FinancialTask(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      targetAmount: json['target_amount']?.toDouble(),
      currentAmount: (json['current_amount'] ?? 0.0).toDouble(),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      taskType: json['task_type'],
      status: json['status'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  double get progressPercentage {
    if (targetAmount == null || targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount!) * 100;
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status == 'active';
  }
}

class BudgetCategory {
  final String id;
  final String userId;
  final String categoryName;
  final double monthlyLimit;
  final double currentSpent;
  final String colorCode;
  final DateTime createdAt;

  BudgetCategory({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.monthlyLimit,
    this.currentSpent = 0.0,
    this.colorCode = '#3498db',
    required this.createdAt,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'],
      userId: json['user_id'],
      categoryName: json['category_name'],
      monthlyLimit: (json['monthly_limit']).toDouble(),
      currentSpent: (json['current_spent'] ?? 0.0).toDouble(),
      colorCode: json['color_code'] ?? '#3498db',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  double get spentPercentage {
    if (monthlyLimit == 0) return 0.0;
    return (currentSpent / monthlyLimit) * 100;
  }

  bool get isOverBudget => currentSpent > monthlyLimit;
  double get remainingBudget => monthlyLimit - currentSpent;
}

class TimelinePost {
  final String id;
  final String userId;
  final String? groupId;
  final String postType;
  final String content;
  final String? expenseId;
  final String visibility;
  final List<String>? mediaUrls;
  final UserProfile? user;
  final Expense? expense;
  final DateTime createdAt;

  TimelinePost({
    required this.id,
    required this.userId,
    this.groupId,
    required this.postType,
    required this.content,
    this.expenseId,
    required this.visibility,
    this.mediaUrls,
    this.user,
    this.expense,
    required this.createdAt,
  });

  factory TimelinePost.fromJson(Map<String, dynamic> json) {
    return TimelinePost(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      postType: json['post_type'],
      content: json['content'],
      expenseId: json['expense_id'],
      visibility: json['visibility'],
      mediaUrls:
          json['media_urls'] != null
              ? List<String>.from(json['media_urls'])
              : null,
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      expense:
          json['expense'] != null ? Expense.fromJson(json['expense']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
