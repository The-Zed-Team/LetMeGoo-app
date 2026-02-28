import 'package:equatable/equatable.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Use case for deleting a vehicle
class DeleteVehicle implements UseCase<bool, DeleteVehicleParams> {
  final VehicleRepository repository;

  DeleteVehicle(this.repository);

  @override
  Future<bool> call(DeleteVehicleParams params) async {
    return await repository.deleteVehicle(params.vehicleId);
  }
}

/// Parameters for deleting a vehicle
class DeleteVehicleParams extends Equatable {
  final String vehicleId;

  const DeleteVehicleParams({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
