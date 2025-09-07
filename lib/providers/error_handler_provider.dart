import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/providers/app_providers.dart';

// Error handling service
class ErrorHandler {
  static void handleError(WidgetRef ref, dynamic error, {String? customMessage}) {
    final errorMessage = customMessage ?? _extractErrorMessage(error);
    
    // Update global snackbar
    ref.read(snackbarProvider.notifier).state = SnackbarMessage(
      message: errorMessage,
      isError: true,
    );
    
    // Log error for debugging
    print('App Error: $error');
    
    // You can add analytics or crash reporting here
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
  
  static String _extractErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    String errorString = error.toString();
    
    // Remove common error prefixes
    errorString = errorString.replaceAll('Exception: ', '');
    errorString = errorString.replaceAll('Error: ', '');
    
    // Handle specific error types
    if (errorString.contains('No internet connection') || 
        errorString.contains('Failed host lookup') ||
        errorString.contains('SocketException')) {
      return 'Please check your internet connection and try again';
    }
    
    if (errorString.contains('timeout') || errorString.contains('TimeoutException')) {
      return 'Request timed out. Please try again';
    }
    
    if (errorString.contains('Authentication') || errorString.contains('Unauthorized')) {
      return 'Authentication failed. Please log in again';
    }
    
    if (errorString.contains('Server error') || errorString.contains('500')) {
      return 'Server error. Please try again later';
    }
    
    // Return cleaned error message or default
    return errorString.isNotEmpty ? errorString : 'Something went wrong. Please try again';
  }
}

// Provider for error handling
final errorHandlerProvider = Provider<ErrorHandler>((ref) => ErrorHandler());
