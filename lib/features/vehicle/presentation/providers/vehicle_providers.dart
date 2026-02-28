import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:letmegoo/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/get_user_vehicles.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/create_vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/delete_vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/search_vehicles.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/get_vehicle_types.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/update_vehicle.dart';

/// Data source provider
final vehicleRemoteDataSourceProvider = Provider<VehicleRemoteDataSource>((
  ref,
) {
  return VehicleRemoteDataSource();
});

/// Repository provider
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final dataSource = ref.watch(vehicleRemoteDataSourceProvider);
  return VehicleRepositoryImpl(remoteDataSource: dataSource);
});

/// Use case providers
final getUserVehiclesUseCaseProvider = Provider<GetUserVehicles>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return GetUserVehicles(repository);
});

final createVehicleUseCaseProvider = Provider<CreateVehicle>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return CreateVehicle(repository);
});

final deleteVehicleUseCaseProvider = Provider<DeleteVehicle>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return DeleteVehicle(repository);
});

final searchVehiclesUseCaseProvider = Provider<SearchVehicles>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return SearchVehicles(repository);
});

final updateVehicleUseCaseProvider = Provider<UpdateVehicle>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return UpdateVehicle(repository);
});

/// Simple user vehicles provider (using FutureProvider for easy consumption)
final userVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final useCase = ref.watch(getUserVehiclesUseCaseProvider);
  return await useCase.call(NoParams());
});

// Provider for GetVehicleTypes use case
final getVehicleTypesUseCaseProvider = Provider<GetVehicleTypes>((ref) {
  return GetVehicleTypes(ref.watch(vehicleRepositoryProvider));
});

// Provider for getting vehicle types easily in UI
final vehicleTypesProvider = FutureProvider<List<VehicleTypeInfo>>((ref) async {
  final useCase = ref.watch(getVehicleTypesUseCaseProvider);
  return await useCase(NoParams());
});
