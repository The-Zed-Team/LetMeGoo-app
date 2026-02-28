import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:letmegoo/core/usecases/usecase.dart';

class GetVehicleTypes implements UseCase<List<VehicleTypeInfo>, NoParams> {
  final VehicleRepository repository;

  const GetVehicleTypes(this.repository);

  @override
  Future<List<VehicleTypeInfo>> call(NoParams params) async {
    return await repository.getVehicleTypes();
  }
}
