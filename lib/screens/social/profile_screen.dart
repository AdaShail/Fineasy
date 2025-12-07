import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/social_models.dart';
import '../../services/social_service.dart';
import '../../providers/auth_provider.dart';

class SocialProfileScreen extends StatefulWidget {
  const SocialProfileScreen({Key? key}) : super(key: key);

  @override
  State<SocialProfileScreen> createState() => _SocialProfileScreenState();
}

class _SocialProfileScreenState extends State<SocialProfileScreen> {
  final SocialService _socialService = SocialService();

  UserProfile? _userProfile;
  List<CorpusTransaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final profile = await _socialService.getUserProfile(
        authProvider.user!.id,
      );
      final transactions = await _socialService.getCorpusHistory(limit: 10);

      setState(() {
        _userProfile = profile;
        _recentTransactions = transactions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
              _showEditProfileDialog();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userProfile == null
              ? _buildCreateProfilePrompt()
              : RefreshIndicator(
                onRefresh: _loadProfileData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildCorpusOverview(),
                      const SizedBox(height: 20),
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCreateProfilePrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Complete Your Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your profile to start using social features',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showCreateProfileDialog,
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  _userProfile!.avatarUrl != null
                      ? NetworkImage(_userProfile!.avatarUrl!)
                      : null,
              child:
                  _userProfile!.avatarUrl == null
                      ? Text(
                        _userProfile!.displayName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              _userProfile!.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '@${_userProfile!.username}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            if (_userProfile!.bio != null) ...[
              const SizedBox(height: 8),
              Text(
                _userProfile!.bio!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Corpus',
                  '\$${_userProfile!.totalCorpus.toStringAsFixed(2)}',
                ),
                _buildStatItem(
                  'Budget',
                  '\$${_userProfile!.monthlyBudget.toStringAsFixed(2)}',
                ),
                _buildStatItem('Joined', _formatDate(_userProfile!.createdAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCorpusOverview() {
    final corpus = _userProfile!.totalCorpus;
    final budget = _userProfile!.monthlyBudget;
    final remaining = budget - corpus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFinancialItem(
                  'Current Corpus',
                  '\$${corpus.toStringAsFixed(2)}',
                  corpus >= 0 ? Colors.green : Colors.red,
                ),
                _buildFinancialItem(
                  'Monthly Budget',
                  '\$${budget.toStringAsFixed(2)}',
                  Colors.blue,
                ),
                _buildFinancialItem(
                  'Remaining',
                  '\$${remaining.toStringAsFixed(2)}',
                  remaining >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: budget > 0 ? (corpus / budget).clamp(0.0, 1.0) : 0.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                corpus > budget ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Text('No transactions yet'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ..._recentTransactions
                .take(5)
                .map((transaction) => _buildTransactionItem(transaction)),
            if (_recentTransactions.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to full transaction history
                },
                child: const Text('View All Transactions'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(CorpusTransaction transaction) {
    final isIncome = transaction.transactionType == 'in';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _formatDate(transaction.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              Text(
                'Balance: \$${transaction.runningBalance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateProfileDialog() {
    final usernameController = TextEditingController();
    final displayNameController = TextEditingController();
    final bioController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Choose a unique username',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Your full name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio (Optional)',
                      hintText: 'Tell others about yourself',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Budget',
                      hintText: '0.00',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (usernameController.text.trim().isEmpty ||
                      displayNameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in required fields'),
                      ),
                    );
                    return;
                  }

                  final budget = double.tryParse(budgetController.text) ?? 0.0;

                  final profile = await _socialService.createUserProfile(
                    username: usernameController.text.trim(),
                    displayName: displayNameController.text.trim(),
                    bio:
                        bioController.text.trim().isEmpty
                            ? null
                            : bioController.text.trim(),
                    monthlyBudget: budget,
                  );

                  Navigator.pop(context);

                  if (profile != null) {
                    _loadProfileData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create profile')),
                    );
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showEditProfileDialog() {
    if (_userProfile == null) return;

    final displayNameController = TextEditingController(
      text: _userProfile!.displayName,
    );
    final bioController = TextEditingController(text: _userProfile!.bio ?? '');
    final budgetController = TextEditingController(
      text: _userProfile!.monthlyBudget.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Budget',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final budget = double.tryParse(budgetController.text) ?? 0.0;

                  final updatedProfile = UserProfile(
                    id: _userProfile!.id,
                    userId: _userProfile!.userId,
                    username: _userProfile!.username,
                    displayName: displayNameController.text.trim(),
                    bio:
                        bioController.text.trim().isEmpty
                            ? null
                            : bioController.text.trim(),
                    avatarUrl: _userProfile!.avatarUrl,
                    phone: _userProfile!.phone,
                    email: _userProfile!.email,
                    isPublic: _userProfile!.isPublic,
                    totalCorpus: _userProfile!.totalCorpus,
                    monthlyBudget: budget,
                    createdAt: _userProfile!.createdAt,
                    updatedAt: DateTime.now(),
                  );

                  final success = await _socialService.updateUserProfile(
                    updatedProfile,
                  );
                  Navigator.pop(context);

                  if (success) {
                    _loadProfileData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update profile')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
