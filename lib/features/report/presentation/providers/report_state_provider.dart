import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/models/report_request.dart';
import 'package:letmegoo/features/report/data/datasources/report_remote_datasource.dart';

/// Provider for report remote datasource
final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSource();
});

/// Provider for managing report submission state
///
/// This provider handles the asynchronous process of submitting a report
/// and maintains the state (loading, success, error) throughout the operation.
final reportStateProvider = StateNotifierProvider<
  ReportStateNotifier,
  AsyncValue<Map<String, dynamic>?>
>((ref) {
  final dataSource = ref.read(reportRemoteDataSourceProvider);
  return ReportStateNotifier(dataSource);
});

/// State notifier for report submission
///
/// Manages the lifecycle of reporting a vehicle including:
/// - Loading state while submitting
/// - Success state with response data
/// - Error state with error details
class ReportStateNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final ReportRemoteDataSource _dataSource;

  ReportStateNotifier(this._dataSource) : super(const AsyncValue.data(null));

  /// Submit a vehicle report
  ///
  /// Takes a [ReportRequest] and submits it to the backend.
  /// Updates state to reflect loading, success, or error states.
  Future<void> reportVehicle(ReportRequest request) async {
    state = const AsyncValue.loading();
    try {
      final result = await _dataSource.reportVehicle(request);
      if (mounted) {
        state = AsyncValue.data(result);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  /// Reset the state back to initial (null data)
  ///
  /// Useful for clearing previous submission results
  void resetState() {
    state = const AsyncValue.data(null);
  }
}
