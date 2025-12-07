import 'package:fineasy/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/invoices/nlp_invoice_screen.dart';
import 'screens/invoices/invoice_list_screen.dart';
import 'screens/invoices/add_edit_invoice_screen.dart';
import 'screens/invoices/ocr_invoice_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/settings/whatsapp_templates_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/receivables/receivables_management_screen.dart';
import 'screens/transactions/transaction_invoice_history_screen.dart';
import 'screens/recurring_payments/recurring_payment_list_screen.dart';
import 'screens/main/main_navigation_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/fraud/fraud_alerts_screen.dart';
import 'screens/customers/add_edit_customer_screen.dart';
import 'screens/suppliers/add_edit_supplier_screen.dart';
import 'screens/payments/payment_management_screen.dart';
import 'screens/onboarding/business_setup_screen.dart';
import 'screens/expenses/add_expense_screen.dart';
// import 'screens/social/groups_screen.dart';
// import 'screens/social/friends_screen.dart';
// import 'screens/chat/chat_list_screen.dart';
// import 'screens/social/profile_screen.dart';
// import 'screens/social/create_profile_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/business_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/product_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/recurring_payment_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/cashbook_provider.dart';
// import 'providers/insights_provider.dart'; // REMOVED - Python dependency
import 'providers/fraud_detection_provider.dart';
// import 'providers/compliance_provider.dart'; // REMOVED - Python dependency
// import 'providers/ai_settings_provider.dart'; // REMOVED - Python dependency
// import 'providers/social_provider.dart';
// import 'services/ai_client_service.dart'; // REMOVED - Python dependency
import 'services/encryption_service.dart';
import 'services/encrypted_storage_service.dart';
import 'services/encrypted_database_service.dart';
import 'config/api_config.dart';

import 'utils/theme_manager.dart';
import 'utils/constants.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/app_lifecycle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate HTTPS configuration before initializing services
  try {
    ApiConfig.validateSecureConnection();
    ApiConfig.printConfig();
  } catch (e) {
    // Log error and exit if HTTPS validation fails in production
    debugPrint('CRITICAL SECURITY ERROR: $e');
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      // In production, we cannot proceed without HTTPS
      throw StateError('Application cannot start: $e');
    }
  }

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize encryption services for data at rest
  await EncryptionService().initialize();
  await EncryptedStorageService().initialize();
  await EncryptedDatabaseService().initialize();

  await ThemeManager().initializeTheme();
  await NotificationService().initialize();
  await SyncService.initialize();

  // Initialize app lifecycle service for session management
  AppLifecycleService().initialize();

  runApp(const FineasyApp());
}

class FineasyApp extends StatelessWidget {
  const FineasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false, // Initialize immediately
        ),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RecurringPaymentProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => CashbookProvider()),
        //ChangeNotifierProvider(create: (_) => InsightsProvider()), // REMOVED - Python dependency
        ChangeNotifierProvider(create: (_) => FraudDetectionProvider()),
        // ChangeNotifierProvider(create: (_) => ComplianceProvider()), // REMOVED - Python dependency
        // ChangeNotifierProvider(create: (_) => AISettingsProvider(AIClientService())), // REMOVED - Python dependency
        // Commented out - Social features disabled
        // ChangeNotifierProvider(create: (_) => SocialProvider()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Fineasy - Business Management',
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: themeManager.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              // Main navigation
              '/home': (context) => const MainNavigationScreen(),
              '/main': (context) => const MainNavigationScreen(),
              // Invoice routes
              '/nlp-invoice': (context) => const NLPInvoiceScreen(),
              '/invoices': (context) => const InvoiceListScreen(),
              '/add-invoice': (context) => const AddEditInvoiceScreen(),
              '/ocr-invoice': (context) => const OCRInvoiceScreen(),

              // Core features
              '/notifications': (context) => const NotificationsScreen(),
              '/search': (context) => const SearchScreen(),
              '/receivables': (context) => const ReceivablesManagementScreen(),
              '/transaction-invoices':
                  (context) => const TransactionInvoiceHistoryScreen(),
              '/recurring-payments':
                  (context) => const RecurringPaymentListScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/reports': (context) => const ReportsScreen(),
              '/fraud-alerts': (context) => const FraudAlertsScreen(),
              '/add-customer': (context) => const AddEditCustomerScreen(),
              '/add-supplier': (context) => const AddEditSupplierScreen(),
              '/payment-management':
                  (context) => const PaymentManagementScreen(),
              '/business-setup': (context) => const BusinessSetupScreen(),
              '/add-expense': (context) => const AddExpenseScreen(),

              // Settings
              '/settings': (context) => const SettingsScreen(),
              '/whatsapp-templates':
                  (context) => const WhatsAppTemplatesScreen(),

              // Social features routes - COMMENTED OUT
              // '/social': (context) => const MainNavigationScreen(),
              // '/groups': (context) => const GroupsScreen(),
              // '/friends': (context) => const FriendsScreen(),
              // '/chats': (context) => const ChatListScreen(),
              // '/social-profile': (context) => const SocialProfileScreen(),
              // '/create-profile': (context) => const CreateProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
