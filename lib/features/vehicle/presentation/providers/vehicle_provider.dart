import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:letmegoo/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/get_user_vehicles.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/create_vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/delete_vehicle.dart';
import 'package:letmegoo/core/usecases/usecase.dart';

part 'vehicle_provider.g.dart';

// ============================================================================
// Dependency Injection Providers
// ============================================================================

@riverpod
VehicleRemoteDataSource vehicleRemoteDataSource(Ref ref) {
  return VehicleRemoteDataSource();
}

@riverpod
VehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepositoryImpl(
    remoteDataSource: ref.watch(vehicleRemoteDataSourceProvider),
  );
}

@riverpod
GetUserVehicles getUserVehiclesUseCase(Ref ref) {
  return GetUserVehicles(ref.watch(vehicleRepositoryProvider));
}

@riverpod
CreateVehicle createVehicleUseCase(Ref ref) {
  return CreateVehicle(ref.watch(vehicleRepositoryProvider));
}

@riverpod
DeleteVehicle deleteVehicleUseCase(Ref ref) {
  return DeleteVehicle(ref.watch(vehicleRepositoryProvider));
}

// ============================================================================
// State Class
// ============================================================================

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
    bool clearError = false,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetch: lastFetch ?? this.lastFetch,
    );
  }

  /// Check if data is stale (older than 3 minutes)
  bool get isDataStale {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch!).inMinutes > 3;
  }
}

// ============================================================================
// Main Vehicle Provider (Notifier)
// ============================================================================

@riverpod
class Vehicles extends _$Vehicles {
  @override
  VehicleState build() {
    return const VehicleState();
  }

  /// Load user vehicles
  Future<void> loadVehicles({bool forceRefresh = false}) async {
    // Avoid redundant calls if data is fresh
    if (!forceRefresh &&
        state.vehicles.isNotEmpty &&
        !state.isDataStale &&
        !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final getVehicles = ref.read(getUserVehiclesUseCaseProvider);
      final vehicles = await getVehicles(const NoParams());
      state = state.copyWith(
        vehicles: vehicles,
        isLoading: false,
        lastFetch: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Create a new vehicle
  Future<Vehicle> createVehicle({
    required String vehicleNumber,
    required String vehicleType,
    String? name,
    String? brand,
    String? fuelType,
    File? image,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final createVehicleUseCase = ref.read(createVehicleUseCaseProvider);
      final vehicle = await createVehicleUseCase(
        CreateVehicleParams(
          vehicleNumber: vehicleNumber,
          vehicleType: vehicleType,
          name: name,
          brand: brand,
          fuelType: fuelType,
          image: image,
        ),
      );

      state = state.copyWith(
        vehicles: [...state.vehicles, vehicle],
        isLoading: false,
      );

      return vehicle;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Delete a vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      final deleteVehicleUseCase = ref.read(deleteVehicleUseCaseProvider);
      final success = await deleteVehicleUseCase(
        DeleteVehicleParams(vehicleId: vehicleId),
      );

      if (success) {
        state = state.copyWith(
          vehicles: state.vehicles.where((v) => v.id != vehicleId).toList(),
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: _getErrorMessage(e));
      rethrow;
    }
  }

  /// Refresh vehicles
  Future<void> refresh() async {
    await loadVehicles(forceRefresh: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear all vehicles
  void clearVehicles() {
    state = const VehicleState();
  }

  String _getErrorMessage(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

// ============================================================================
// Convenience Providers
// ============================================================================

@riverpod
List<Vehicle> vehiclesList(Ref ref) {
  return ref.watch(vehiclesProvider).vehicles;
}

@riverpod
bool isVehiclesLoading(Ref ref) {
  return ref.watch(vehiclesProvider).isLoading;
}

@riverpod
bool hasVehicles(Ref ref) {
  return ref.watch(vehiclesProvider).vehicles.isNotEmpty;
}

@riverpod
int vehicleCount(Ref ref) {
  return ref.watch(vehiclesProvider).vehicles.length;
}
