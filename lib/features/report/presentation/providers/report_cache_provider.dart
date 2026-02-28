import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_cache_provider.g.dart';

/// Provider for managing report cache timestamps
///
/// Tracks when reports were last fetched to determine if cached data is still valid
@riverpod
class ReportsCache extends _$ReportsCache {
  static const cacheDuration = Duration(minutes: 5);

  @override
  DateTime? build() {
    return null;
  }

  /// Update cache timestamp to now
  void updateCacheTime() {
    state = DateTime.now();
  }

  /// Check if cache is still valid
  bool get isCacheValid {
    if (state == null) return false;
    return DateTime.now().difference(state!).inMinutes <
        cacheDuration.inMinutes;
  }

  /// Clear cache
  void clearCache() {
    state = null;
  }
}
