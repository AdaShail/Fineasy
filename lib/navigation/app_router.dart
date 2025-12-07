import 'package:flutter/material.dart';
import '../screens/main/main_navigation_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/social/groups_screen.dart';
import '../screens/social/friends_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/social/profile_screen.dart';

class AppRouter {
  static const String main = '/';
  static const String search = '/search';
  static const String groups = '/groups';
  static const String friends = '/friends';
  static const String chats = '/chats';
  static const String addExpense = '/add-expense';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());

      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case groups:
        return MaterialPageRoute(builder: (_) => const GroupsScreen());

      case friends:
        return MaterialPageRoute(builder: (_) => const FriendsScreen());

      case chats:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case addExpense:
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const SocialProfileScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('Page Not Found')),
                body: const Center(child: Text('Page not found')),
              ),
        );
    }
  }

  // Helper methods for programmatic navigation
  static void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, search);
  }

  static void navigateToGroups(BuildContext context) {
    Navigator.pushNamed(context, groups);
  }

  static void navigateToFriends(BuildContext context) {
    Navigator.pushNamed(context, friends);
  }

  static void navigateToChats(BuildContext context) {
    Navigator.pushNamed(context, chats);
  }

  static void navigateToAddExpense(BuildContext context) {
    Navigator.pushNamed(context, addExpense);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }
}
