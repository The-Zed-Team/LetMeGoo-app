import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/repositories/vehicle_repository.dart';

/// Use case for searching vehicles
class SearchVehicles implements UseCase<List<Vehicle>, SearchVehiclesParams> {
  final VehicleRepository repository;

  const SearchVehicles(this.repository);

  @override
  Future<List<Vehicle>> call(SearchVehiclesParams params) async {
    return await repository.searchVehicles(
      params.query,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

/// Parameters for searching vehicles
class SearchVehiclesParams {
  final String query;
  final double? latitude;
  final double? longitude;

  const SearchVehiclesParams({
    required this.query,
    this.latitude,
    this.longitude,
  });
}
