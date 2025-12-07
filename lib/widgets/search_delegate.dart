import 'package:flutter/material.dart';
import '../models/social_models.dart';
import '../services/social_service.dart';

class UserSearchDelegate extends SearchDelegate<UserProfile?> {
  final SocialService _socialService = SocialService();

  @override
  String get searchFieldLabel => 'Search users and groups...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches();
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    return FutureBuilder<List<UserProfile>>(
      future: _socialService.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No users found'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                child:
                    user.avatarUrl == null
                        ? Text(user.displayName.substring(0, 1).toUpperCase())
                        : null,
              ),
              title: Text(user.displayName),
              subtitle: Text('@${user.username}'),
              trailing: IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () async {
                  final success = await _socialService.sendFriendRequest(
                    user.id,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend request sent!')),
                    );
                  }
                },
              ),
              onTap: () {
                close(context, user);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Search for users and groups'),
          SizedBox(height: 8),
          Text(
            'Find friends to connect with and groups to join',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
