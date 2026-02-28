import 'package:flutter/foundation.dart';

/// Application-wide logging utility
///
/// Replaces direct print() calls with production-safe logging.
/// Only outputs in debug mode, preventing log spam in production.
class AppLogger {
  /// Standard log message
  ///
  /// Usage: `AppLogger.log('User logged in', tag: 'AUTH');`
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Log an error with optional exception and stack trace
  ///
  /// Usage: `AppLogger.error('Failed to load', error: e, stackTrace: st);`
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('${prefix}ERROR: $message');
      if (error != null) debugPrint('  Exception: $error');
      if (stackTrace != null) debugPrint('  Stack trace:\n$stackTrace');
    }
  }

  /// Log a warning
  ///
  /// Usage: `AppLogger.warn('Deprecated API used', tag: 'DEPRECATION');`
  static void warn(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('${prefix}WARNING: $message');
    }
  }

  /// Log debug information (verbose)
  ///
  /// Usage: `AppLogger.debug('Cache hit for key: $key', tag: 'CACHE');`
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('${prefix}DEBUG: $message');
    }
  }
}
