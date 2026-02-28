import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/get_user_vehicles.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/delete_vehicle.dart';
import 'package:letmegoo/features/vehicle/presentation/providers/vehicle_providers.dart';

/// State for managing user vehicles with loading/error states
class UserVehiclesState {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final String? errorMessage;

  const UserVehiclesState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  UserVehiclesState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserVehiclesState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// StateNotifier for managing user vehicles
class UserVehiclesNotifier extends StateNotifier<UserVehiclesState> {
  final GetUserVehicles getUserVehiclesUseCase;
  final DeleteVehicle deleteVehicleUseCase;

  UserVehiclesNotifier({
    required this.getUserVehiclesUseCase,
    required this.deleteVehicleUseCase,
  }) : super(const UserVehiclesState());

  /// Load user vehicles
  Future<void> loadVehicles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final vehicles = await getUserVehiclesUseCase(NoParams());
      state = state.copyWith(
        vehicles: vehicles,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Refresh user vehicles
  Future<void> refreshVehicles() async {
    await loadVehicles();
  }

  /// Delete a vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await deleteVehicleUseCase(DeleteVehicleParams(vehicleId: vehicleId));
      // Remove from local state
      final updatedVehicles =
          state.vehicles.where((v) => v.id != vehicleId).toList();
      state = state.copyWith(vehicles: updatedVehicles);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete vehicle: $e');
      return false;
    }
  }

  /// Get vehicle type display value from the vehicle type key
  /// Returns the display-friendly vehicle type (e.g., "car" -> "Car")
  String getVehicleTypeDisplay(String vehicleTypeKey) {
    // Map common vehicle types - this matches the backend format
    final typeMap = {
      'two_wheeler': 'Two Wheeler',
      'three_wheeler': 'Three Wheeler',
      'four_wheeler': 'Four Wheeler',
      'heavy_vehicle': 'Heavy Vehicle',
    };

    return typeMap[vehicleTypeKey] ?? vehicleTypeKey;
  }
}

/// Provider for UserVehiclesNotifier
final userVehiclesNotifierProvider =
    StateNotifierProvider<UserVehiclesNotifier, UserVehiclesState>((ref) {
      return UserVehiclesNotifier(
        getUserVehiclesUseCase: ref.watch(getUserVehiclesUseCaseProvider),
        deleteVehicleUseCase: ref.watch(deleteVehicleUseCaseProvider),
      );
    });
