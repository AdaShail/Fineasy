import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../screens/main/main_navigation_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/social/groups_screen.dart';
import '../screens/social/friends_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/social/profile_screen.dart';
import '../screens/invoices/invoice_list_screen.dart';
import '../screens/customers/customer_list_screen.dart';
import '../screens/suppliers/supplier_list_screen.dart';
import '../screens/transactions/transaction_hub_screen.dart';
import '../screens/payments/payment_management_screen.dart';
import '../screens/receivables/receivables_management_screen.dart';
import '../screens/recurring_payments/recurring_payment_list_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/autopilot/autopilot_chat_screen.dart' show AutoPilotChatScreen;
import '../screens/settings/settings_screen.dart';
import '../web/navigation/web_navigation_shell.dart';
import '../web/screens/web_reports_analytics_screen.dart';

class AppRouter {
  // Main routes
  static const String main = '/';
  static const String search = '/search';
  
  // Core feature routes
  static const String invoices = '/invoices';
  static const String customers = '/customers';
  static const String suppliers = '/suppliers';
  static const String transactions = '/transactions';
  static const String payments = '/payments';
  static const String receivables = '/receivables';
  static const String recurringPayments = '/recurring-payments';
  static const String reports = '/reports';
  static const String autopilot = '/autopilot';
  static const String settings = '/settings';
  
  // Social routes
  static const String groups = '/groups';
  static const String friends = '/friends';
  static const String chats = '/chats';
  static const String addExpense = '/add-expense';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';
    
    // Wrap in web navigation shell if on web platform
    Widget buildScreen(Widget screen) {
      if (kIsWeb) {
        return WebNavigationShell(
          currentRoute: routeName,
          child: screen,
        );
      }
      return screen;
    }
    
    switch (routeName) {
      case main:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const MainNavigationScreen()),
          settings: settings,
        );

      case invoices:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const InvoiceListScreen()),
          settings: settings,
        );

      case customers:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const CustomerListScreen()),
          settings: settings,
        );

      case suppliers:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const SupplierListScreen()),
          settings: settings,
        );

      case transactions:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const TransactionHubScreen()),
          settings: settings,
        );

      case payments:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const PaymentManagementScreen()),
          settings: settings,
        );

      case receivables:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const ReceivablesManagementScreen()),
          settings: settings,
        );

      case recurringPayments:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const RecurringPaymentListScreen()),
          settings: settings,
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => buildScreen(
            kIsWeb ? const WebReportsAnalyticsScreen() : const ReportsScreen(),
          ),
          settings: settings,
        );

      case autopilot:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const AutoPilotChatScreen()),
          settings: settings,
        );

      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const SettingsScreen()),
          settings: settings,
        );

      case search:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const SearchScreen()),
          settings: settings,
        );

      case groups:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const GroupsScreen()),
          settings: settings,
        );

      case friends:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const FriendsScreen()),
          settings: settings,
        );

      case chats:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const ChatListScreen()),
          settings: settings,
        );

      case addExpense:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const AddExpenseScreen()),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => buildScreen(const SocialProfileScreen()),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => buildScreen(
                Scaffold(
                  appBar: AppBar(title: const Text('Page Not Found')),
                  body: const Center(child: Text('Page not found')),
                ),
              ),
          settings: settings,
        );
    }
  }

  // Helper methods for programmatic navigation
  static void navigateToMain(BuildContext context) {
    Navigator.pushNamed(context, main);
  }

  static void navigateToInvoices(BuildContext context) {
    Navigator.pushNamed(context, invoices);
  }

  static void navigateToCustomers(BuildContext context) {
    Navigator.pushNamed(context, customers);
  }

  static void navigateToSuppliers(BuildContext context) {
    Navigator.pushNamed(context, suppliers);
  }

  static void navigateToTransactions(BuildContext context) {
    Navigator.pushNamed(context, transactions);
  }

  static void navigateToPayments(BuildContext context) {
    Navigator.pushNamed(context, payments);
  }

  static void navigateToReceivables(BuildContext context) {
    Navigator.pushNamed(context, receivables);
  }

  static void navigateToRecurringPayments(BuildContext context) {
    Navigator.pushNamed(context, recurringPayments);
  }

  static void navigateToReports(BuildContext context) {
    Navigator.pushNamed(context, reports);
  }

  static void navigateToAutopilot(BuildContext context) {
    Navigator.pushNamed(context, autopilot);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, settings);
  }

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
