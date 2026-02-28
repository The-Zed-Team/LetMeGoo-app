// Custom exceptions for the application
//
// These exceptions are thrown by data sources and should be caught
// and converted to Failures in repositories.

/// Exception thrown when there's a server error
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Server error occurred',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception thrown when there's no internet connection
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when authentication fails
class AuthException implements Exception {
  final String message;

  const AuthException({this.message = 'Authentication failed'});

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when user is forbidden (403)
class ForbiddenException implements Exception {
  final String message;

  const ForbiddenException({this.message = 'Access forbidden'});

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception thrown when resource is not found (404)
class NotFoundException implements Exception {
  final String message;

  const NotFoundException({this.message = 'Resource not found'});

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when there's a cache error
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    this.message = 'Validation failed',
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown for general API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({this.message = 'API error occurred', this.statusCode});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Exception thrown for connectivity/network issues
class ConnectivityException implements Exception {
  final String message;

  const ConnectivityException({this.message = 'Connectivity error'});

  @override
  String toString() => 'ConnectivityException: $message';
}
