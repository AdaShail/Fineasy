import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/social_models.dart';
import '../../services/social_service.dart';
import '../../services/chat_service.dart';
import '../../services/timeline_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final ExpenseGroup group;

  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with TickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  final ChatService _chatService = ChatService();
  final TimelineService _timelineService = TimelineService();

  late TabController _tabController;

  List<Expense> _groupExpenses = [];
  List<UserProfile> _groupMembers = [];
  List<TimelinePost> _groupActivity = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGroupData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupData() async {
    setState(() => _isLoading = true);

    try {
      // Load group expenses
      final expenses = await _socialService.getExpenses(
        groupId: widget.group.id,
      );

      // Load group members (you'll need to implement this)
      final members = await _loadGroupMembers();

      // Load group activity
      final activity = await _timelineService.getTimelineFeed(
        groupId: widget.group.id,
      );

      // Calculate totals
      final income = expenses
          .where((e) => e.transactionType == 'income')
          .fold(0.0, (sum, e) => sum + e.amount);
      final expenseTotal = expenses
          .where((e) => e.transactionType == 'expense')
          .fold(0.0, (sum, e) => sum + e.amount);

      setState(() {
        _groupExpenses = expenses;
        _groupMembers = members;
        _groupActivity = activity;
        _totalIncome = income;
        _totalExpenses = expenseTotal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading group data: $e')));
    }
  }

  Future<List<UserProfile>> _loadGroupMembers() async {
    // This is a placeholder - you'll need to implement this in SocialService
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final balance = _totalIncome - _totalExpenses;
    final budgetUsed =
        widget.group.groupBudget > 0
            ? (_totalExpenses / widget.group.groupBudget) * 100
            : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _openGroupChat(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareInviteCode(),
          ),
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit Group'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'members',
                    child: Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 8),
                        Text('Manage Members'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Leave Group',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editGroup();
                  break;
                case 'members':
                  _manageMembers();
                  break;
                case 'leave':
                  _leaveGroup();
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Expenses'),
            Tab(text: 'Members'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Group Budget Overview
                  _buildBudgetOverview(balance, budgetUsed),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildExpensesTab(),
                        _buildMembersTab(),
                        _buildActivityTab(),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        heroTag: "group_detail_add_expense_fab",
        onPressed: () => _addGroupExpense(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetOverview(double balance, double budgetUsed) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Income',
                  '\$${_totalIncome.toStringAsFixed(2)}',
                  Colors.green,
                  Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Expenses',
                  '\$${_totalExpenses.toStringAsFixed(2)}',
                  Colors.red,
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Balance',
                  '\$${balance.toStringAsFixed(2)}',
                  balance >= 0 ? Colors.green : Colors.red,
                  balance >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Budget Progress
          if (widget.group.groupBudget > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget: \$${widget.group.groupBudget.toStringAsFixed(2)}',
                ),
                Text('${budgetUsed.toStringAsFixed(1)}% used'),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (budgetUsed / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                budgetUsed > 100 ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (widget.group.description != null) ...[
                    Text('Description: ${widget.group.description}'),
                    const SizedBox(height: 8),
                  ],
                  Text('Created: ${_formatDate(widget.group.createdAt)}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Invite Code: ${widget.group.inviteCode}'),
                      IconButton(
                        onPressed: () => _copyInviteCode(),
                        icon: const Icon(Icons.copy, size: 16),
                      ),
                    ],
                  ),
                  Text('Members: ${_groupMembers.length}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Expenses
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Expenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_groupExpenses.isEmpty)
                    const Text('No expenses yet')
                  else
                    ..._groupExpenses
                        .take(5)
                        .map((expense) => _buildExpenseItem(expense)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_groupExpenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No expenses yet'),
            Text('Add the first group expense!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groupExpenses.length,
      itemBuilder: (context, index) {
        final expense = _groupExpenses[index];
        return _buildExpenseItem(expense);
      },
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groupMembers.length,
      itemBuilder: (context, index) {
        final member = _groupMembers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
            child:
                member.avatarUrl == null
                    ? Text(member.displayName.substring(0, 1).toUpperCase())
                    : null,
          ),
          title: Text(member.displayName),
          subtitle: Text('@${member.username}'),
          trailing: PopupMenuButton(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'chat',
                    child: Row(
                      children: [
                        Icon(Icons.chat),
                        SizedBox(width: 8),
                        Text('Message'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              // Handle member actions
            },
          ),
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groupActivity.length,
      itemBuilder: (context, index) {
        final post = _groupActivity[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  post.user?.avatarUrl != null
                      ? NetworkImage(post.user!.avatarUrl!)
                      : null,
              child:
                  post.user?.avatarUrl == null
                      ? Text(
                        post.user?.displayName.substring(0, 1).toUpperCase() ??
                            '?',
                      )
                      : null,
            ),
            title: Text(post.user?.displayName ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.content),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(post.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    final isIncome = expense.transactionType == 'income';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(expense.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${expense.category} • ${expense.user?.displayName ?? 'Unknown'}',
            ),
            Text(_formatDate(expense.date)),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  void _openGroupChat() async {
    // Create or get group chat room
    final chatRoom = await _chatService.createGroupChat(
      widget.group.id,
      widget.group.name,
    );
    if (chatRoom != null) {
      // Navigate to chat screen (you'll need to implement this)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Group chat opened!')));
    }
  }

  void _shareInviteCode() {
    Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invite code "${widget.group.inviteCode}" copied to clipboard!',
        ),
      ),
    );
  }

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite code copied!')));
  }

  void _addGroupExpense() {
    Navigator.pushNamed(
      context,
      '/add-expense',
      arguments: {'group': widget.group},
    ).then((_) => _loadGroupData());
  }

  void _editGroup() {
    // Navigate to edit group screen
  }

  void _manageMembers() {
    // Navigate to manage members screen
  }

  void _leaveGroup() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave Group'),
            content: Text(
              'Are you sure you want to leave "${widget.group.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement leave group functionality
                },
                child: const Text('Leave', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
