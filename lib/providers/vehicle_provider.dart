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
    if (!forceRefresh && state.vehicles.isNotEmpty && !state.isDataStale && !state.isLoading) {
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
      return vehicleType['value']?.toString() ??
          vehicleType['key']?.toString() ??
          'Unknown';
    } else {
      return vehicleType.toString();
    }
  }

  // Get vehicle by ID
  Vehicle? getVehicleById(String vehicleId) {
    try {
      return state.vehicles.firstWhere((vehicle) => vehicle.id == vehicleId);
    } catch (e) {
      return null;
    }
  }

  // Get vehicles count
  int get vehicleCount => state.vehicles.length;

  // Check if user has any verified vehicles
  bool get hasVerifiedVehicles => state.vehicles.any((vehicle) => vehicle.isVerified);

  // Get only verified vehicles
  List<Vehicle> get verifiedVehicles => state.vehicles.where((vehicle) => vehicle.isVerified).toList();
}

final vehicleProvider = StateNotifierProvider<VehicleNotifier, VehicleState>((
  ref,
) {
  return VehicleNotifier();
});
