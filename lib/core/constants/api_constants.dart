/// API constants for LetMeGoo application
///
/// Centralizes all API-related constants to avoid magic strings
/// and make configuration changes easier.
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  /// Base API URL
  static const String baseUrl = 'https://api.letmegoo.com/api';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 10);

  /// Connectivity check timeout
  static const Duration connectivityTimeout = Duration(seconds: 5);

  /// Cache validity duration for vehicle types
  static const Duration cacheValidity = Duration(hours: 1);

  /// Debounce duration for search operations
  static const Duration debounceDuration = Duration(milliseconds: 500);

  /// Default pagination limits
  static const int defaultLimit = 50;
  static const int defaultOffset = 0;

  /// Content type headers
  static const String jsonContentType = 'application/json';
  static const String formUrlEncodedContentType =
      'application/x-www-form-urlencoded';
}
