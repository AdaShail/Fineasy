import 'package:flutter/material.dart';
import 'social_dashboard_screen.dart';
import 'friends_screen.dart';
import 'groups_screen.dart';
import 'profile_screen.dart';
import '../chat/chat_list_screen.dart';

/// Integration helper for adding social features to existing app
class SocialIntegration {
  /// Navigate to main social dashboard
  static void navigateToSocialDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SocialDashboardScreen()),
    );
  }

  /// Navigate to friends management
  static void navigateToFriends(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FriendsScreen()),
    );
  }

  /// Navigate to groups management
  static void navigateToGroups(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsScreen()),
    );
  }

  /// Navigate to social profile (different from existing profile)
  static void navigateToSocialProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SocialProfileScreen()),
    );
  }

  /// Navigate to chat list
  static void navigateToChats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatListScreen()),
    );
  }

  /// Add social features to existing drawer/navigation
  static List<Widget> getSocialDrawerItems(BuildContext context) {
    return [
      const Divider(),
      const ListTile(
        leading: Icon(Icons.people),
        title: Text('Social Features'),
        enabled: false,
      ),
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Social Dashboard'),
        onTap: () {
          Navigator.pop(context);
          navigateToSocialDashboard(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.people),
        title: const Text('Friends'),
        onTap: () {
          Navigator.pop(context);
          navigateToFriends(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.group),
        title: const Text('Groups'),
        onTap: () {
          Navigator.pop(context);
          navigateToGroups(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.chat),
        title: const Text('Chats'),
        onTap: () {
          Navigator.pop(context);
          navigateToChats(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.person_outline),
        title: const Text('Social Profile'),
        onTap: () {
          Navigator.pop(context);
          navigateToSocialProfile(context);
        },
      ),
    ];
  }

  /// Add social features to existing bottom navigation
  static List<BottomNavigationBarItem> getSocialBottomNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Social',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
      const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
    ];
  }

  /// Handle bottom navigation tap for social features
  static void handleSocialBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        navigateToSocialDashboard(context);
        break;
      case 1:
        navigateToFriends(context);
        break;
      case 2:
        navigateToChats(context);
        break;
    }
  }

  /// Add social action buttons to existing app bar
  static List<Widget> getSocialAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.people),
        tooltip: 'Friends',
        onPressed: () => navigateToFriends(context),
      ),
      IconButton(
        icon: const Icon(Icons.chat_bubble_outline),
        tooltip: 'Chats',
        onPressed: () => navigateToChats(context),
      ),
    ];
  }

  /// Create floating action button with social options
  static Widget getSocialFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showSocialOptions(context),
      child: const Icon(Icons.add),
    );
  }

  static void _showSocialOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Add Expense'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to your existing add expense screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: const Text('Create Group'),
                  onTap: () {
                    Navigator.pop(context);
                    navigateToGroups(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Add Friend'),
                  onTap: () {
                    Navigator.pop(context);
                    navigateToFriends(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Social Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    navigateToSocialDashboard(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
