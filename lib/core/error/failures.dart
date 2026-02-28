import 'package:equatable/equatable.dart';

/// Failure classes for the domain layer
///
/// These represent error states that are passed from repositories
/// to use cases and presentation layer.

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An error occurred'});

  @override
  List<Object?> get props => [message];
}

/// Server failure (API errors)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Server error occurred',
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Network failure (no internet)
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed'});
}

/// Forbidden failure (403)
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Access forbidden'});
}

/// Not found failure (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found'});
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}
