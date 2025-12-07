import 'package:flutter/material.dart';
import '../../models/social_models.dart';
import '../../services/social_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  late TabController _tabController;

  List<UserProfile> _friends = [];
  List<UserConnection> _friendRequests = [];
  List<UserProfile> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriendsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    setState(() => _isLoading = true);

    final friends = await _socialService.getFriends();
    final requests = await _socialService.getFriendRequests();

    setState(() {
      _friends = friends;
      _friendRequests = requests;
      _isLoading = false;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final results = await _socialService.searchUsers(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _sendFriendRequest(String userId) async {
    final success = await _socialService.sendFriendRequest(userId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request sent!')));
      // Remove from search results
      setState(() {
        _searchResults.removeWhere((user) => user.id == userId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  Future<void> _acceptFriendRequest(String connectionId) async {
    final success = await _socialService.acceptFriendRequest(connectionId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Friend request accepted!')));
      _loadFriendsData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept friend request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Friends (${_friends.length})'),
            Tab(text: 'Requests (${_friendRequests.length})'),
            const Tab(text: 'Search'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsList(),
                  _buildFriendRequests(),
                  _buildSearchTab(),
                ],
              ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No friends yet'),
            Text('Search for users to add as friends!'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendsData,
      child: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return _buildFriendTile(friend);
        },
      ),
    );
  }

  Widget _buildFriendTile(UserProfile friend) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
        child:
            friend.avatarUrl == null
                ? Text(friend.displayName.substring(0, 1).toUpperCase())
                : null,
      ),
      title: Text(friend.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('@${friend.username}'),
          if (friend.bio != null)
            Text(friend.bio!, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            'Corpus: \$${friend.totalCorpus.toStringAsFixed(2)}',
            style: TextStyle(
              color: friend.totalCorpus >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton(
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'chat',
                child: Row(
                  children: [
                    Icon(Icons.chat),
                    SizedBox(width: 8),
                    Text('Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('View Profile'),
                  ],
                ),
              ),
            ],
        onSelected: (value) {
          switch (value) {
            case 'chat':
              // Navigate to chat
              break;
            case 'profile':
              // Navigate to profile
              break;
          }
        },
      ),
      onTap: () {
        // Navigate to friend's profile or start chat
      },
    );
  }

  Widget _buildFriendRequests() {
    if (_friendRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No friend requests'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final request = _friendRequests[index];
        final requester = request.requester!;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  requester.avatarUrl != null
                      ? NetworkImage(requester.avatarUrl!)
                      : null,
              child:
                  requester.avatarUrl == null
                      ? Text(
                        requester.displayName.substring(0, 1).toUpperCase(),
                      )
                      : null,
            ),
            title: Text(requester.displayName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${requester.username}'),
                if (requester.bio != null)
                  Text(
                    requester.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  'Sent ${_formatTimeAgo(request.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _acceptFriendRequest(request.id),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Decline friend request
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search users by username or name...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _searchUsers,
          ),
        ),
        Expanded(
          child:
              _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Search for users to add as friends'
                              : 'No users found',
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return _buildSearchResultTile(user);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildSearchResultTile(UserProfile user) {
    return ListTile(
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
            Text(user.bio!, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: ElevatedButton.icon(
        onPressed: () => _sendFriendRequest(user.id),
        icon: const Icon(Icons.person_add, size: 16),
        label: const Text('Add'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(80, 32)),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
