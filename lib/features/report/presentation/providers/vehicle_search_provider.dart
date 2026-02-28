import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/presentation/providers/vehicle_providers.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/search_vehicles.dart';
import 'package:letmegoo/core/utils/logger.dart';

/// Provider for managing vehicle search state
///
/// This provider handles searching for vehicles by registration number
/// and optionally with location coordinates.
final vehicleSearchProvider =
    StateNotifierProvider<VehicleSearchNotifier, AsyncValue<Vehicle?>>((ref) {
      final searchVehiclesUseCase = ref.watch(searchVehiclesUseCaseProvider);
      return VehicleSearchNotifier(searchVehiclesUseCase);
    });

/// State notifier for vehicle search functionality
///
/// Manages the lifecycle of searching for a vehicle including:
/// - Loading state while searching
/// - Success state with vehicle data
/// - Error state with error details
/// - Handling empty search results
class VehicleSearchNotifier extends StateNotifier<AsyncValue<Vehicle?>> {
  final SearchVehicles searchVehiclesUseCase;

  VehicleSearchNotifier(this.searchVehiclesUseCase)
    : super(const AsyncValue.data(null));

  /// Search for a vehicle by registration number
  ///
  /// [registrationNumber] - The vehicle registration/license plate number
  /// [latitude] - Optional latitude for location-based search
  /// [longitude] - Optional longitude for location-based search
  ///
  /// Updates state with the first matching vehicle or null if not found.
  Future<void> searchVehicle(
    String registrationNumber, {
    double? latitude,
    double? longitude,
  }) async {
    state = const AsyncValue.loading();
    try {
      AppLogger.debug('🔍 Starting vehicle search for: $registrationNumber');
      if (latitude != null && longitude != null) {
        AppLogger.debug('📍 Using location: $latitude, $longitude');
      } else {
        AppLogger.debug('📍 No location provided for search');
      }

      // Use the clean architecture use case
      final results = await searchVehiclesUseCase.call(
        SearchVehiclesParams(
          query: registrationNumber,
          latitude: latitude,
          longitude: longitude,
        ),
      );

      AppLogger.debug('📊 Search results count: ${results.length}');

      if (results.isNotEmpty) {
        final firstResult = results.first;
        AppLogger.debug('✅ Found vehicle: ${firstResult.toString()}');

        // The use case already returns Vehicle entities
        final vehicle = firstResult;

        if (mounted) {
          state = AsyncValue.data(vehicle);
        }
      } else {
        AppLogger.debug('❌ No vehicles found');
        if (mounted) {
          state = const AsyncValue.data(null);
        }
      }
    } catch (e, stackTrace) {
      AppLogger.debug('❌ Vehicle search error: $e');
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  /// Reset the state back to initial (null data)
  ///
  /// Useful for clearing previous search results
  void resetState() {
    state = const AsyncValue.data(null);
  }
}
