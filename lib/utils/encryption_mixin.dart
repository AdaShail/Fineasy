import '../services/encryption_service.dart';

/// Mixin for models that contain sensitive data requiring encryption
/// Provides helper methods for encrypting and decrypting model data
mixin EncryptionMixin {
  final _encryptionService = EncryptionService();

  /// List of field names that should be encrypted
  /// Override this in your model to specify sensitive fields
  List<String> get sensitiveFields => [];

  /// Encrypt the model's sensitive fields before storage
  Future<Map<String, dynamic>> encryptForStorage(
    Map<String, dynamic> json,
  ) async {
    if (sensitiveFields.isEmpty) return json;

    return await _encryptionService.encryptSensitiveFields(
      json,
      sensitiveFields,
    );
  }

  /// Decrypt the model's sensitive fields after retrieval
  Future<Map<String, dynamic>> decryptFromStorage(
    Map<String, dynamic> json,
  ) async {
    if (sensitiveFields.isEmpty) return json;

    return await _encryptionService.decryptSensitiveFields(
      json,
      sensitiveFields,
    );
  }

  /// Encrypt a specific field value
  Future<String> encryptField(String value) async {
    return await _encryptionService.encryptString(value);
  }

  /// Decrypt a specific field value
  Future<String> decryptField(String encryptedValue) async {
    return await _encryptionService.decryptString(encryptedValue);
  }
}

/// Extension for common sensitive data patterns
extension SensitiveDataPatterns on List<String> {
  /// Common sensitive fields for financial data
  static List<String> get financialFields => [
    'account_number',
    'bank_account',
    'card_number',
    'cvv',
    'pin',
    'routing_number',
    'ifsc_code',
    'swift_code',
  ];

  /// Common sensitive fields for personal data
  static List<String> get personalFields => [
    'ssn',
    'pan',
    'aadhar',
    'passport_number',
    'driving_license',
    'tax_id',
    'national_id',
  ];

  /// Common sensitive fields for authentication
  static List<String> get authFields => [
    'password',
    'password_hash',
    'api_key',
    'secret_key',
    'access_token',
    'refresh_token',
    'private_key',
  ];

  /// Common sensitive fields for business data
  static List<String> get businessFields => [
    'gstin',
    'tan',
    'cin',
    'business_registration',
    'license_number',
  ];

  /// All common sensitive fields combined
  static List<String> get allCommonFields => [
    ...financialFields,
    ...personalFields,
    ...authFields,
    ...businessFields,
  ];
}
