import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:letmegoo/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:letmegoo/features/shop/domain/repositories/shop_repository.dart';
import 'package:letmegoo/features/shop/domain/usecases/get_shops.dart';
import 'package:letmegoo/features/shop/domain/usecases/get_shops_with_distance.dart';

/// Provider for shop remote datasource
final shopRemoteDataSourceProvider = Provider<ShopRemoteDataSource>((ref) {
  return ShopRemoteDataSource();
});

/// Provider for shop repository
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final dataSource = ref.read(shopRemoteDataSourceProvider);
  return ShopRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for GetShops use case
final getShopsUseCaseProvider = Provider<GetShops>((ref) {
  final repository = ref.read(shopRepositoryProvider);
  return GetShops(repository);
});

/// Provider for GetShopsWithDistance use case
final getShopsWithDistanceUseCaseProvider = Provider<GetShopsWithDistance>((
  ref,
) {
  final repository = ref.read(shopRepositoryProvider);
  return GetShopsWithDistance(repository);
});
