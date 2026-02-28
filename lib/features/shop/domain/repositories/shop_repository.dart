import 'package:letmegoo/features/shop/domain/entities/shop.dart';
import 'package:letmegoo/features/shop/domain/entities/shop_list_result.dart';

/// Repository interface for shop data operations
abstract class ShopRepository {
  /// Get paginated list of shops
  Future<ShopListResult> getShops({int offset = 0, int limit = 50});

  /// Get shops with distance calculated from user's location
  ///
  /// If [userLatitude] and [userLongitude] are provided, the distance
  /// field will be populated for each shop.
  Future<List<Shop>> getShopsWithDistance({
    int offset = 0,
    int limit = 10,
    double? userLatitude,
    double? userLongitude,
  });
}
