import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/dio_service.dart';
import '../services/storage_service.dart';

// Storage service provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return StorageService(sharedPrefs);
});

// Dio service provider
final dioServiceProvider = Provider<DioService>((ref) {
  return DioService();
});

final dioProvider = Provider<Dio>((ref) {
  final dioService = ref.watch(dioServiceProvider);
  return dioService.dio;
});

// Setup function
Future<void> setupDependencyInjection() async {
  final sharedPrefs = await SharedPreferences.getInstance();

  // Create a container to override providers
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
  );

  // You can add more initialization logic here
}
