import 'dart:io';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:letmegoo/core/usecases/usecase.dart';

class UpdateVehicle implements UseCase<Vehicle, UpdateVehicleParams> {
  final VehicleRepository repository;

  UpdateVehicle(this.repository);

  @override
  Future<Vehicle> call(UpdateVehicleParams params) async {
    return await repository.updateVehicle(
      vehicleId: params.vehicleId,
      vehicleNumber: params.vehicleNumber,
      vehicleType: params.vehicleType,
      name: params.name,
      brand: params.brand,
      fuelType: params.fuelType,
      image: params.image,
    );
  }
}

class UpdateVehicleParams {
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleType;
  final String? name;
  final String? brand;
  final String? fuelType;
  final File? image;

  UpdateVehicleParams({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleType,
    this.name,
    this.brand,
    this.fuelType,
    this.image,
  });
}
