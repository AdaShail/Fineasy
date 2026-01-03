import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Supabase Configuration
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? 
      const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://jfsbkeljaslollwkyxia.supabase.co');
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? 
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impmc2JrZWxqYXNsb2xsd2t5eGlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzNTQ3ODgsImV4cCI6MjA3MDkzMDc4OH0.f19Lrtw1m5qitFXWOTKe8wPv7blsAbJq-eBKddbU-1E');
  static String get supabaseServiceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? 
      const String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY', defaultValue: '');

  // Firebase Configuration
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Fineasy';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // Currency
  static String get defaultCurrency => dotenv.env['DEFAULT_CURRENCY'] ?? '₹';
  static String get currencyCode =>
      dotenv.env['DEFAULT_CURRENCY_CODE'] ?? 'INR';

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String businessDataKey = 'business_data';
  static const String offlineTransactionsKey = 'offline_transactions';
  static const String offlineCustomersKey = 'offline_customers';
  static const String offlineSuppliersKey = 'offline_suppliers';
  static const String syncQueueKey = 'sync_queue';

  // API Endpoints (Optional - only needed for custom API endpoints)
  static String get baseApiUrl => dotenv.env['BASE_API_URL'] ?? '';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // Feature Flags
  static bool get enableOfflineSync =>
      dotenv.env['ENABLE_OFFLINE_SYNC']?.toLowerCase() == 'true';
  static bool get enablePushNotifications =>
      dotenv.env['ENABLE_PUSH_NOTIFICATIONS']?.toLowerCase() == 'true';
  static bool get enableContactIntegration =>
      dotenv.env['ENABLE_CONTACT_INTEGRATION']?.toLowerCase() == 'true';
  static bool get enablePdfReports =>
      dotenv.env['ENABLE_PDF_REPORTS']?.toLowerCase() == 'true';

  // Development
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';

  // Pagination
  static const int defaultPageSize = 20;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Business Categories
  static const List<String> businessCategories = [
    'Retail',
    'Wholesale',
    'Manufacturing',
    'Services',
    'Restaurant',
    'Medical',
    'Education',
    'Real Estate',
    'Construction',
    'Transportation',
    'Technology',
    'Agriculture',
    'Other',
  ];

  // Payment Modes
  static const List<String> paymentModes = [
    'Cash',
    'Card',
    'UPI',
    'Net Banking',
    'Cheque',
    'Bank Transfer',
    'Other',
  ];

  // Countries with Currency
  static const Map<String, Map<String, String>> countries = {
    'India': {'currency': '₹', 'code': 'INR'},
    'United States': {'currency': '\$', 'code': 'USD'},
    'United Kingdom': {'currency': '£', 'code': 'GBP'},
    'European Union': {'currency': '€', 'code': 'EUR'},
    'Canada': {'currency': 'C\$', 'code': 'CAD'},
    'Australia': {'currency': 'A\$', 'code': 'AUD'},
  };
}
