// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportsCacheHash() => r'9e32c7781e4405e6eb3151969797db2b8aea5636';

/// Provider for managing report cache timestamps
///
/// Tracks when reports were last fetched to determine if cached data is still valid
///
/// Copied from [ReportsCache].
@ProviderFor(ReportsCache)
final reportsCacheProvider =
    AutoDisposeNotifierProvider<ReportsCache, DateTime?>.internal(
      ReportsCache.new,
      name: r'reportsCacheProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$reportsCacheHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReportsCache = AutoDisposeNotifier<DateTime?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
