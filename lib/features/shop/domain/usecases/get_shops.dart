import 'package:letmegoo/features/shop/domain/entities/shop_list_result.dart';
import 'package:letmegoo/features/shop/domain/repositories/shop_repository.dart';

/// Use case for getting paginated list of shops
class GetShops {
  final ShopRepository repository;

  GetShops(this.repository);

  Future<ShopListResult> call({int offset = 0, int limit = 50}) {
    return repository.getShops(offset: offset, limit: limit);
  }
}
