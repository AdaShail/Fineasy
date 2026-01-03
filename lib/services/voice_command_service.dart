import 'package:flutter/foundation.dart';
import 'dart:async';

/// Stub version of Voice Command Service
/// Speech-to-text temporarily disabled due to package compatibility issues
class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  
  factory VoiceCommandService() => _instance;
  
  VoiceCommandService._internal();

  bool _isInitialized = false;

  /// Initialize voice command service (stub)
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = true;
    return false; // Not available
  }

  /// Start listening (stub)
  Future<void> startListening({Duration? timeout}) async {
  }

  /// Stop listening (stub)
  Future<void> stopListening() async {
  }

  /// Process text command (stub)
  Future<Map<String, dynamic>> processCommand(String text) async {
    return {
      'success': false,
      'message': 'Voice commands not available',
    };
  }

  /// Speak text (stub)
  Future<void> speak(String text) async {
  }

  /// Set language (stub)
  Future<bool> setLanguage(String locale) async {
    return false;
  }

  /// Get available languages (stub)
  Future<List<String>> getAvailableLanguages() async {
    return ['en_US'];
  }

  /// Check if listening (stub)
  bool get isListening => false;

  /// Check if initialized (stub)
  bool get isInitialized => _isInitialized;

  /// Dispose (stub)
  void dispose() {
  }
}
