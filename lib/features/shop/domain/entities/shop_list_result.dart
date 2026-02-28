import 'package:letmegoo/features/shop/domain/entities/shop.dart';

/// Result from paginated shop list query
class ShopListResult {
  final int limit;
  final int offset;
  final String? next;
  final String? previous;
  final List<Shop> shops;

  const ShopListResult({
    required this.limit,
    required this.offset,
    this.next,
    this.previous,
    required this.shops,
  });
}
