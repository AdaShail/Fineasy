import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/social_models.dart';
import '../../services/social_service.dart';
import '../../services/timeline_service.dart';
import '../../providers/auth_provider.dart';
import '../chat/chat_list_screen.dart';
import '../social/friends_screen.dart';
import '../social/groups_screen.dart';
import '../social/profile_screen.dart';
import '../expenses/add_expense_screen.dart';
// import '../../widgets/ai_backend_test_widget.dart'; // Commented out - file not found

class SocialDashboardScreen extends StatefulWidget {
  const SocialDashboardScreen({super.key});

  @override
  State<SocialDashboardScreen> createState() => _SocialDashboardScreenState();
}

class _SocialDashboardScreenState extends State<SocialDashboardScreen> {
  final SocialService _socialService = SocialService();
  final TimelineService _timelineService = TimelineService();

  UserProfile? _userProfile;
  List<TimelinePost> _timelinePosts = [];
  List<FinancialTask> _upcomingTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final profile = await _socialService.getUserProfile(
        authProvider.user!.id,
      );
      final posts = await _timelineService.getTimelineFeed(limit: 10);
      final tasks = await _socialService.getFinancialTasks();

      setState(() {
        _userProfile = profile;
        _timelinePosts = posts;
        _upcomingTasks = tasks.take(3).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinEasy Social'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatListScreen(),
                  ),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SocialProfileScreen(),
                  ),
                ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCorpusOverview(),
                      const SizedBox(height: 20),
                      // const AIBackendTestWidget(), // Commented out - widget not available
                      const SizedBox(height: 20),
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                      _buildUpcomingTasks(),
                      const SizedBox(height: 20),
                      _buildTimelineFeed(),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        heroTag: "social_dashboard_add_expense_fab",
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCorpusOverview() {
    if (_userProfile == null) return const SizedBox.shrink();

    final corpus = _userProfile!.totalCorpus;
    final budget = _userProfile!.monthlyBudget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Corpus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '\$${corpus.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: corpus >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Monthly Budget: \$${budget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Remaining: \$${(budget - corpus).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionButton(
                  icon: Icons.people,
                  label: 'Friends',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FriendsScreen(),
                        ),
                      ),
                ),
                _buildActionButton(
                  icon: Icons.group,
                  label: 'Groups',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroupsScreen(),
                        ),
                      ),
                ),
                _buildActionButton(
                  icon: Icons.chat,
                  label: 'Chat',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatListScreen(),
                        ),
                      ),
                ),
                _buildActionButton(
                  icon: Icons.add_circle,
                  label: 'Add Expense',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddExpenseScreen(),
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 25, child: Icon(icon)),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTasks() {
    if (_upcomingTasks.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Tasks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._upcomingTasks.map((task) => _buildTaskItem(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(FinancialTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            task.taskType == 'goal' ? Icons.flag : Icons.alarm,
            size: 16,
            color: task.isOverdue ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(context).textTheme.bodyMedium),
                if (task.targetAmount != null)
                  Text(
                    'Target: \$${task.targetAmount!.toStringAsFixed(2)} (${task.progressPercentage.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (task.dueDate != null)
            Text(
              '${task.dueDate!.day}/${task.dueDate!.month}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: task.isOverdue ? Colors.red : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineFeed() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_timelinePosts.isEmpty)
              const Center(
                child: Text(
                  'No recent activity. Start by adding friends or joining groups!',
                ),
              )
            else
              ..._timelinePosts.take(5).map((post) => _buildTimelineItem(post)),
            if (_timelinePosts.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to full timeline
                },
                child: const Text('View All Activity'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TimelinePost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: post.user?.displayName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${post.content}'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(post.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
