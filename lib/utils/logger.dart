import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Global logger instance for the application
///
/// Usage:
/// ```dart
/// import '../utils/logger.dart';
///
/// logger.d('Debug message');
/// logger.i('Info message');
/// logger.w('Warning message');
/// logger.e('Error message', error: error, stackTrace: stackTrace);
/// ```
final logger = Logger(
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: kDebugMode ? Level.debug : Level.info,
);

/// Custom filter that allows all logs in debug mode
/// and only warnings and errors in production
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) {
      return true;
    }
    // In production, only log warnings and errors
    return event.level.index >= Level.warning.index;
  }
}
