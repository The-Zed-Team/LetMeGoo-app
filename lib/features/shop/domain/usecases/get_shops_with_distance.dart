import 'package:letmegoo/features/shop/domain/entities/shop.dart';
import 'package:letmegoo/features/shop/domain/repositories/shop_repository.dart';

/// Use case for getting shops with distance calculation
class GetShopsWithDistance {
  final ShopRepository repository;

  GetShopsWithDistance(this.repository);

  Future<List<Shop>> call({
    int offset = 0,
    int limit = 10,
    double? userLatitude,
    double? userLongitude,
  }) {
    return repository.getShopsWithDistance(
      offset: offset,
      limit: limit,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );
  }
}
