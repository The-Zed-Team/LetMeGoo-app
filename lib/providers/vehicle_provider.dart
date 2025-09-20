// lib/providers/vehicle_provider.dart - Updated version
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/services/auth_service.dart';
import 'package:letmegoo/models/vehicle.dart';

// Vehicle data state
class VehicleState {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastFetch;

  const VehicleState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastFetch,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastFetch,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastFetch: lastFetch ?? this.lastFetch,
    );
  }

  // Check if data is stale (older than 3 minutes for vehicles)
  bool get isDataStale {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch!).inMinutes > 3;
  }
}

// Vehicle provider
class VehicleNotifier extends StateNotifier<VehicleState> {
  VehicleNotifier() : super(const VehicleState());

  Future<void> loadVehicles({bool forceRefresh = false}) async {
    // Avoid redundant calls if data is fresh and not forcing refresh
    if (!forceRefresh &&
        state.vehicles.isNotEmpty &&
        !state.isDataStale &&
        !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final vehicles = await AuthService.getUserVehicles();
      state = state.copyWith(
        vehicles: vehicles,
        isLoading: false,
        errorMessage: null,
        lastFetch: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow; // Re-throw for error handling at UI level if needed
    }
  }

  Future<void> refreshVehicles() async {
    await loadVehicles(forceRefresh: true);
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      final success = await AuthService.deleteVehicle(vehicleId);

      if (success) {
        // Remove vehicle from local state
        final updatedVehicles =
            state.vehicles.where((vehicle) => vehicle.id != vehicleId).toList();
        state = state.copyWith(vehicles: updatedVehicles);
        return true;
      }
      return false;
    } catch (e) {
      // Don't update state on error, let the UI handle it
      rethrow;
    }
  }

  void clearVehicles() {
    state = const VehicleState();
  }

  // Helper method to get vehicle type display value
  String getVehicleTypeDisplay(dynamic vehicleType) {
    if (vehicleType == null) return 'Unknown';

    if (vehicleType is String) {
      return vehicleType;
    } else if (vehicleType is Map<String, dynamic>) {
      return vehicleType['value']?.toString() ?? 'Unknown';
    }

    return 'Unknown';
  }
}

// Vehicle provider instance
final vehicleProvider = StateNotifierProvider<VehicleNotifier, VehicleState>(
  (ref) => VehicleNotifier(),
);

// Alternative: AsyncValue-based provider for better loading states
final vehiclesAsyncProvider = FutureProvider<List<Vehicle>>((ref) async {
  return await AuthService.getUserVehicles();
});

// You might also want to add these convenience providers:

// Provider to get just the vehicles list
final vehiclesListProvider = Provider<List<Vehicle>>((ref) {
  return ref.watch(vehicleProvider).vehicles;
});

// Provider to check if vehicles are loading
final vehiclesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(vehicleProvider).isLoading;
});

// Provider to get vehicle error message
final vehicleErrorProvider = Provider<String?>((ref) {
  return ref.watch(vehicleProvider).errorMessage;
});

// Provider to check if user has any vehicles
final hasVehiclesProvider = Provider<bool>((ref) {
  return ref.watch(vehicleProvider).vehicles.isNotEmpty;
});
