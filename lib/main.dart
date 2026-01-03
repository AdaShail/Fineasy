import 'package:fineasy/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/invoices/nlp_invoice_screen.dart';
import 'screens/invoices/add_edit_invoice_screen.dart';
import 'screens/invoices/ocr_invoice_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/settings/whatsapp_templates_screen.dart';
import 'screens/transactions/transaction_invoice_history_screen.dart';
import 'screens/fraud/fraud_alerts_screen.dart';
import 'screens/customers/add_edit_customer_screen.dart';
import 'screens/suppliers/add_edit_supplier_screen.dart';
import 'screens/onboarding/business_setup_screen.dart';
import 'navigation/app_router.dart';
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

  try {
    // Validate HTTPS configuration before initializing services
    try {
      ApiConfig.validateSecureConnection();
      ApiConfig.printConfig();
    } catch (e) {
      // Log error and exit if HTTPS validation fails in production
      const bool isProduction = bool.fromEnvironment('dart.vm.product');
      if (isProduction) {
        // In production, we cannot proceed without HTTPS
        throw StateError('Application cannot start: $e');
      }
    }

    // Load environment variables (skip on web if file doesn't exist)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Continue anyway - constants might be hardcoded or from build args
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Initialize encryption services for data at rest (skip on web if not supported)
    try {
      await EncryptionService().initialize();
      await EncryptedStorageService().initialize();
      await EncryptedDatabaseService().initialize();
    } catch (e) {
      // Continue anyway - web might not support all encryption features
    }

    await ThemeManager().initializeTheme();
    
    // Initialize notification service (skip on web if not supported)
    try {
      await NotificationService().initialize();
    } catch (e) {
    }
    
    await SyncService.initialize();

    // Initialize app lifecycle service for session management
    AppLifecycleService().initialize();

    runApp(const FineasyApp());
  } catch (e, stackTrace) {
    // Show error screen instead of blank loading
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Reload the page
                    // ignore: avoid_web_libraries_in_flutter
                    // html.window.location.reload();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class FineasyApp extends StatelessWidget {
  const FineasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the singleton ThemeManager instance that was initialized in main()
    final themeManager = ThemeManager();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
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
            onGenerateRoute: AppRouter.generateRoute,
            routes: {
              // Additional routes not handled by AppRouter
              '/home': (context) => const SplashScreen(),
              '/main': (context) => const SplashScreen(),
              '/nlp-invoice': (context) => const NLPInvoiceScreen(),
              '/add-invoice': (context) => const AddEditInvoiceScreen(),
              '/ocr-invoice': (context) => const OCRInvoiceScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/transaction-invoices':
                  (context) => const TransactionInvoiceHistoryScreen(),
              '/fraud-alerts': (context) => const FraudAlertsScreen(),
              '/add-customer': (context) => const AddEditCustomerScreen(),
              '/add-supplier': (context) => const AddEditSupplierScreen(),
              '/business-setup': (context) => const BusinessSetupScreen(),
              '/whatsapp-templates':
                  (context) => const WhatsAppTemplatesScreen(),
            },
          );
        },
      ),
    );
  }
}
