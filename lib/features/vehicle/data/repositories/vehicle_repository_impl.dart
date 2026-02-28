import 'dart:io';
import 'package:letmegoo/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Implementation of VehicleRepository
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  List<Vehicle> _cachedVehicles = [];
  List<VehicleTypeInfo> _cachedVehicleTypes = [];

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Vehicle>> getUserVehicles() async {
    final vehicleDtos = await remoteDataSource.getUserVehicles();
    _cachedVehicles = vehicleDtos.map((dto) => dto.toEntity()).toList();
    return _cachedVehicles;
  }

  @override
  Future<Vehicle> getVehicleById(String vehicleId) async {
    final vehicleDto = await remoteDataSource.getVehicleById(vehicleId);
    return vehicleDto.toEntity();
  }

  @override
  Future<Vehicle> createVehicle({
    required String vehicleNumber,
    required String vehicleType,
    String? name,
    String? brand,
    String? fuelType,
    File? image,
  }) async {
    final vehicleDto = await remoteDataSource.createVehicle(
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      name: name,
      brand: brand,
      fuelType: fuelType,
      image: image,
    );
    final vehicle = vehicleDto.toEntity();
    _cachedVehicles.add(vehicle);
    return vehicle;
  }

  @override
  Future<Vehicle> updateVehicle({
    required String vehicleId,
    required String vehicleNumber,
    required String vehicleType,
    String? name,
    String? brand,
    String? fuelType,
    File? image,
  }) async {
    final vehicleDto = await remoteDataSource.updateVehicle(
      vehicleId: vehicleId,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      name: name,
      brand: brand,
      fuelType: fuelType,
      image: image,
    );
    final vehicle = vehicleDto.toEntity();

    // Update cache
    final index = _cachedVehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _cachedVehicles[index] = vehicle;
    }

    return vehicle;
  }

  @override
  Future<bool> deleteVehicle(String vehicleId) async {
    final success = await remoteDataSource.deleteVehicle(vehicleId);
    if (success) {
      _cachedVehicles.removeWhere((v) => v.id == vehicleId);
    }
    return success;
  }

  @override
  Future<List<Vehicle>> searchVehicles(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    final vehicleDtos = await remoteDataSource.searchVehicles(
      query,
      latitude: latitude,
      longitude: longitude,
    );
    return vehicleDtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<VehicleTypeInfo>> getVehicleTypes() async {
    if (_cachedVehicleTypes.isNotEmpty) {
      return _cachedVehicleTypes;
    }
    final typeDtos = await remoteDataSource.getVehicleTypes();
    _cachedVehicleTypes = typeDtos.map((dto) => dto.toEntity()).toList();
    return _cachedVehicleTypes;
  }

  @override
  List<Vehicle> getCachedVehicles() => _cachedVehicles;

  @override
  void clearCache() {
    _cachedVehicles = [];
    _cachedVehicleTypes = [];
  }
}
