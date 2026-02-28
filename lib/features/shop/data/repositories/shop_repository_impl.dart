import 'package:geolocator/geolocator.dart';
import 'package:letmegoo/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:letmegoo/features/shop/domain/entities/shop.dart';
import 'package:letmegoo/features/shop/domain/entities/shop_list_result.dart';
import 'package:letmegoo/features/shop/domain/repositories/shop_repository.dart';

/// Implementation of ShopRepository
class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ShopListResult> getShops({int offset = 0, int limit = 50}) async {
    try {
      final responseDto = await remoteDataSource.getShops(
        offset: offset,
        limit: limit,
      );

      final shops = responseDto.items.map((dto) => dto.toEntity()).toList();

      return ShopListResult(
        limit: responseDto.limit,
        offset: responseDto.offset,
        next: responseDto.next,
        previous: responseDto.previous,
        shops: shops,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Shop>> getShopsWithDistance({
    int offset = 0,
    int limit = 10,
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      final shopListResult = await getShops(offset: offset, limit: limit);

      // Calculate distances if user location is provided
      if (userLatitude != null && userLongitude != null) {
        return shopListResult.shops.map((shop) {
          final distance =
              Geolocator.distanceBetween(
                userLatitude,
                userLongitude,
                shop.latitude,
                shop.longitude,
              ) /
              1000; // Convert meters to kilometers

          return shop.copyWith(distance: distance);
        }).toList();
      }

      return shopListResult.shops;
    } catch (e) {
      rethrow;
    }
  }
}
