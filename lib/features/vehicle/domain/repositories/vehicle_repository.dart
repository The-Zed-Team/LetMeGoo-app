import 'dart:io';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';

/// Abstract repository for vehicle operations
abstract class VehicleRepository {
  /// Get all user vehicles
  Future<List<Vehicle>> getUserVehicles();

  /// Get vehicle by ID
  Future<Vehicle> getVehicleById(String vehicleId);

  /// Create a new vehicle
  Future<Vehicle> createVehicle({
    required String vehicleNumber,
    required String vehicleType,
    String? name,
    String? brand,
    String? fuelType,
    File? image,
  });

  /// Update a vehicle
  Future<Vehicle> updateVehicle({
    required String vehicleId,
    required String vehicleNumber,
    required String vehicleType,
    String? name,
    String? brand,
    String? fuelType,
    File? image,
  });

  /// Delete a vehicle
  Future<bool> deleteVehicle(String vehicleId);

  /// Search vehicles
  Future<List<Vehicle>> searchVehicles(
    String query, {
    double? latitude,
    double? longitude,
  });

  /// Get available vehicle types
  Future<List<VehicleTypeInfo>> getVehicleTypes();

  /// Get cached vehicles
  List<Vehicle> getCachedVehicles();

  /// Clear vehicle cache
  void clearCache();
}
