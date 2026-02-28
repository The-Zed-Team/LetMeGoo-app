import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Use case for creating a vehicle
class CreateVehicle implements UseCase<Vehicle, CreateVehicleParams> {
  final VehicleRepository repository;

  CreateVehicle(this.repository);

  @override
  Future<Vehicle> call(CreateVehicleParams params) async {
    return await repository.createVehicle(
      vehicleNumber: params.vehicleNumber,
      vehicleType: params.vehicleType,
      name: params.name,
      brand: params.brand,
      fuelType: params.fuelType,
      image: params.image,
    );
  }
}

/// Parameters for creating a vehicle
class CreateVehicleParams extends Equatable {
  final String vehicleNumber;
  final String vehicleType;
  final String? name;
  final String? brand;
  final String? fuelType;
  final File? image;

  const CreateVehicleParams({
    required this.vehicleNumber,
    required this.vehicleType,
    this.name,
    this.brand,
    this.fuelType,
    this.image,
  });

  @override
  List<Object?> get props => [
    vehicleNumber,
    vehicleType,
    name,
    brand,
    fuelType,
    image?.path,
  ];
}
