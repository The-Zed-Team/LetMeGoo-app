import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Global loading state for app-wide operations
final globalLoadingProvider = StateProvider<bool>((ref) => false);

// Snackbar message provider
class SnackbarMessage {
  final String message;
  final bool isError;
  final DateTime timestamp;

  SnackbarMessage({required this.message, required this.isError})
    : timestamp = DateTime.now();
}

final snackbarProvider = StateProvider<SnackbarMessage?>((ref) => null);

// Network connectivity provider with real connectivity monitoring
final connectivityProvider = StreamProvider<bool>((ref) async* {
  await for (final connectivityResult in Connectivity().onConnectivityChanged) {
    yield connectivityResult != ConnectivityResult.none;
  }
});

// App lifecycle provider
final appLifecycleProvider = StateProvider<bool>((ref) => true);

// Cache invalidation provider for refreshing data
final cacheInvalidationProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Helper method to invalidate cache and refresh data
void invalidateCache(WidgetRef ref) {
  ref.read(cacheInvalidationProvider.notifier).state = DateTime.now();
}
