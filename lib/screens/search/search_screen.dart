import 'package:flutter/material.dart';
import '../../models/social_models.dart';
import '../../services/social_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  List<UserProfile> _userResults = [];
  List<ExpenseGroup> _groupResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _userResults = [];
        _groupResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Search users
      final users = await _socialService.searchUsers(query);

      // Search groups (you'll need to implement this in SocialService)
      final groups = await _searchGroups(query);

      setState(() {
        _userResults = users;
        _groupResults = groups;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    }
  }

  Future<List<ExpenseGroup>> _searchGroups(String query) async {
    // This is a placeholder - you'll need to implement group search in SocialService
    // For now, return empty list
    return [];
  }

  Future<void> _sendFriendRequest(String userId) async {
    final success = await _socialService.sendFriendRequest(userId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request sent!')));
      // Remove from search results
      setState(() {
        _userResults.removeWhere((user) => user.id == userId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users and groups...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: _performSearch,
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Users (${_userResults.length})'),
                  Tab(text: 'Groups (${_groupResults.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body:
          _isSearching
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [_buildUsersTab(), _buildGroupsTab()],
              ),
    );
  }

  Widget _buildUsersTab() {
    if (!_hasSearched) {
      return _buildEmptyState(
        icon: Icons.search,
        title: 'Search for Users',
        subtitle: 'Enter a username or name to find people',
      );
    }

    if (_userResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search,
        title: 'No Users Found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildGroupsTab() {
    if (!_hasSearched) {
      return _buildEmptyState(
        icon: Icons.search,
        title: 'Search for Groups',
        subtitle: 'Enter a group name to find expense groups',
      );
    }

    if (_groupResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_off,
        title: 'No Groups Found',
        subtitle: 'Try a different search term or create a new group',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groupResults.length,
      itemBuilder: (context, index) {
        final group = _groupResults[index];
        return _buildGroupTile(group);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserProfile user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child:
              user.avatarUrl == null
                  ? Text(user.displayName.substring(0, 1).toUpperCase())
                  : null,
        ),
        title: Text(user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${user.username}'),
            if (user.bio != null)
              Text(
                user.bio!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _sendFriendRequest(user.id),
          icon: const Icon(Icons.person_add, size: 16),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 32)),
        ),
        onTap: () {
          // Navigate to user profile
        },
      ),
    );
  }

  Widget _buildGroupTile(ExpenseGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            group.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(group.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description != null)
              Text(
                group.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              'Budget: \$${group.groupBudget.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: OutlinedButton(
          onPressed: () {
            // Show join group dialog or navigate to group details
          },
          child: const Text('View'),
        ),
        onTap: () {
          // Navigate to group details
        },
      ),
    );
  }
}
