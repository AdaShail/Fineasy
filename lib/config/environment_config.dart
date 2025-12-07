/// Environment configuration for the app
/// Supports multiple deployment environments
class EnvironmentConfig {
  // Supabase Configuration
  static String get supabaseUrl => const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://your-project.supabase.co',
      );

  static String get supabaseAnonKey => const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      );

  // AI Backend Configuration
  static String get aiBackendUrl => const String.fromEnvironment(
        'AI_BACKEND_URL',
        defaultValue: 'https://your-backend.railway.app',
      );

  static String get geminiApiKey => const String.fromEnvironment(
        'GEMINI_API_KEY',
        defaultValue: '',
      );

  // WhatsApp Configuration (Optional)
  static String get whatsappBusinessPhoneId => const String.fromEnvironment(
        'WHATSAPP_BUSINESS_PHONE_ID',
        defaultValue: '',
      );

  static String get whatsappAccessToken => const String.fromEnvironment(
        'WHATSAPP_ACCESS_TOKEN',
        defaultValue: '',
      );

  // Environment detection
  static bool get isProduction => const bool.fromEnvironment(
        'PRODUCTION',
        defaultValue: false,
      );

  static bool get isDevelopment => !isProduction;

  // Feature flags
  static bool get enableAnalytics => const bool.fromEnvironment(
        'ENABLE_ANALYTICS',
        defaultValue: true,
      );

  static bool get enableCrashReporting => const bool.fromEnvironment(
        'ENABLE_CRASH_REPORTING',
        defaultValue: true,
      );

  // Validation
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        aiBackendUrl.isNotEmpty;
  }

  // Debug info
  static Map<String, dynamic> get debugInfo => {
        'supabaseUrl': supabaseUrl,
        'aiBackendUrl': aiBackendUrl,
        'isProduction': isProduction,
        'isConfigured': isConfigured,
        'hasSupabaseKey': supabaseAnonKey.isNotEmpty,
        'hasGeminiKey': geminiApiKey.isNotEmpty,
      };
}
