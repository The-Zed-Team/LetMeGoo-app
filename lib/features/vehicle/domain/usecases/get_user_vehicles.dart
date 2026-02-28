import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Use case for getting all user vehicles
class GetUserVehicles implements UseCase<List<Vehicle>, NoParams> {
  final VehicleRepository repository;

  GetUserVehicles(this.repository);

  @override
  Future<List<Vehicle>> call(NoParams params) async {
    return await repository.getUserVehicles();
  }
}
