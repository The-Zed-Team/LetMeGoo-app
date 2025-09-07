import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:letmegoo/models/report.dart';
import 'package:letmegoo/services/auth_service.dart';

part 'report_providers.g.dart';

// Exception classes
class ConnectivityException implements Exception {
  final String message;
  ConnectivityException(this.message);

  @override
  String toString() => 'ConnectivityException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

// State class for reports
// State class for reports
class ReportsState {
  final List<Report> liveByUser;
  final List<Report> liveAgainstUser;
  final List<Report> solvedByUser;
  final List<Report> solvedAgainstUser;
  final bool isLoading;
  final bool isRefreshing; // Add this
  final String? error;

  const ReportsState({
    this.liveByUser = const [],
    this.liveAgainstUser = const [],
    this.solvedByUser = const [],
    this.solvedAgainstUser = const [],
    this.isLoading = false,
    this.isRefreshing = false, // Add this
    this.error,
  });

  ReportsState copyWith({
    List<Report>? liveByUser,
    List<Report>? liveAgainstUser,
    List<Report>? solvedByUser,
    List<Report>? solvedAgainstUser,
    bool? isLoading,
    bool? isRefreshing, // Add this
    String? error,
    bool clearError = false,
  }) {
    return ReportsState(
      liveByUser: liveByUser ?? this.liveByUser,
      liveAgainstUser: liveAgainstUser ?? this.liveAgainstUser,
      solvedByUser: solvedByUser ?? this.solvedByUser,
      solvedAgainstUser: solvedAgainstUser ?? this.solvedAgainstUser,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing, // Add this
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasNoReports =>
      liveByUser.isEmpty &&
      liveAgainstUser.isEmpty &&
      solvedByUser.isEmpty &&
      solvedAgainstUser.isEmpty;

  int get totalReports =>
      liveByUser.length +
      liveAgainstUser.length +
      solvedByUser.length +
      solvedAgainstUser.length;

  // Add these helper getters
  bool get shouldShowLoading => isLoading && hasNoReports;
  bool get shouldShowRefreshIndicator => isRefreshing && !hasNoReports;

  @override
  String toString() {
    return 'ReportsState(liveByUser: ${liveByUser.length}, liveAgainstUser: ${liveAgainstUser.length}, solvedByUser: ${solvedByUser.length}, solvedAgainstUser: ${solvedAgainstUser.length}, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error)';
  }
}

// Individual report providers for better granular control
@riverpod
Future<List<Report>> liveReportsByUser(LiveReportsByUserRef ref) async {
  try {
    return await AuthService.getLiveReportsByUser();
  } catch (e) {
    throw ApiException('Failed to load live reports by user: ${e.toString()}');
  }
}

@riverpod
Future<List<Report>> liveReportsAgainstUser(
  LiveReportsAgainstUserRef ref,
) async {
  try {
    return await AuthService.getLiveReportsAgainstUser();
  } catch (e) {
    throw ApiException(
      'Failed to load live reports against user: ${e.toString()}',
    );
  }
}

@riverpod
Future<List<Report>> solvedReportsByUser(SolvedReportsByUserRef ref) async {
  try {
    return await AuthService.getSolvedReportsByUser();
  } catch (e) {
    throw ApiException(
      'Failed to load solved reports by user: ${e.toString()}',
    );
  }
}

@riverpod
Future<List<Report>> solvedReportsAgainstUser(
  SolvedReportsAgainstUserRef ref,
) async {
  try {
    return await AuthService.getSolvedReportsAgainstUser();
  } catch (e) {
    throw ApiException(
      'Failed to load solved reports against user: ${e.toString()}',
    );
  }
}

// Main reports provider that combines all data
@riverpod
class Reports extends _$Reports {
  @override
  ReportsState build() {
    return const ReportsState();
  }

  // Load all reports
  Future<void> loadReports() async {
    if (state.isLoading) return; // Prevent multiple simultaneous loads

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Use Future.wait for concurrent loading
      final results = await Future.wait([
        ref.read(liveReportsByUserProvider.future),
        ref.read(liveReportsAgainstUserProvider.future),
        ref.read(solvedReportsByUserProvider.future),
        ref.read(solvedReportsAgainstUserProvider.future),
      ]);

      state = state.copyWith(
        liveByUser: results[0],
        liveAgainstUser: results[1],
        solvedByUser: results[2],
        solvedAgainstUser: results[3],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      rethrow; // Re-throw for UI error handling if needed
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    try {
      // Invalidate all individual providers
      ref.invalidate(liveReportsByUserProvider);
      ref.invalidate(liveReportsAgainstUserProvider);
      ref.invalidate(solvedReportsByUserProvider);
      ref.invalidate(solvedReportsAgainstUserProvider);

      // Reload data
      await loadReports();
    } catch (e) {
      // Error is already handled in loadReports
      rethrow;
    }
  }

  // Add a new report (optimistic update)
  void addReport(Report report, String category) {
    try {
      switch (category.toLowerCase()) {
        case 'livebyuser':
        case 'live_by_user':
          state = state.copyWith(liveByUser: [...state.liveByUser, report]);
          break;
        case 'liveagainstuser':
        case 'live_against_user':
          state = state.copyWith(
            liveAgainstUser: [...state.liveAgainstUser, report],
          );
          break;
        case 'solvedbyuser':
        case 'solved_by_user':
          state = state.copyWith(solvedByUser: [...state.solvedByUser, report]);
          break;
        case 'solvedagainstuser':
        case 'solved_against_user':
          state = state.copyWith(
            solvedAgainstUser: [...state.solvedAgainstUser, report],
          );
          break;
        default:
          throw ArgumentError('Invalid category: $category');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to add report: ${e.toString()}');
    }
  }

  // Remove a report
  void removeReport(String reportId) {
    try {
      state = state.copyWith(
        liveByUser: state.liveByUser.where((r) => r.id != reportId).toList(),
        liveAgainstUser:
            state.liveAgainstUser.where((r) => r.id != reportId).toList(),
        solvedByUser:
            state.solvedByUser.where((r) => r.id != reportId).toList(),
        solvedAgainstUser:
            state.solvedAgainstUser.where((r) => r.id != reportId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove report: ${e.toString()}');
    }
  }

  // Move report from live to solved (optimistic update)
  void markReportAsSolved(String reportId, bool isReportedByUser) {
    try {
      if (isReportedByUser) {
        final reportIndex = state.liveByUser.indexWhere(
          (r) => r.id == reportId,
        );
        if (reportIndex == -1) {
          throw ArgumentError('Report not found in liveByUser');
        }

        final report = state.liveByUser[reportIndex];
        final updatedReport = Report(
          id: report.id,
          reportNumber: report.reportNumber,
          vehicle: report.vehicle,
          notes: report.notes,
          currentStatus: 'solved',
          isClosed: true,
          isAnonymous: report.isAnonymous,
          reporter: report.reporter,
          createdAt: report.createdAt,
          updatedAt: DateTime.now(),
          latitude: report.latitude,
          longitude: report.longitude,
          location: report.location,
          images: report.images,
          statusLogs: report.statusLogs,
        );

        state = state.copyWith(
          liveByUser: state.liveByUser.where((r) => r.id != reportId).toList(),
          solvedByUser: [...state.solvedByUser, updatedReport],
        );
      } else {
        final reportIndex = state.liveAgainstUser.indexWhere(
          (r) => r.id == reportId,
        );
        if (reportIndex == -1) {
          throw ArgumentError('Report not found in liveAgainstUser');
        }

        final report = state.liveAgainstUser[reportIndex];
        final updatedReport = Report(
          id: report.id,
          reportNumber: report.reportNumber,
          vehicle: report.vehicle,
          notes: report.notes,
          currentStatus: 'solved',
          isClosed: true,
          isAnonymous: report.isAnonymous,
          reporter: report.reporter,
          createdAt: report.createdAt,
          updatedAt: DateTime.now(),
          latitude: report.latitude,
          longitude: report.longitude,
          location: report.location,
          images: report.images,
          statusLogs: report.statusLogs,
        );

        state = state.copyWith(
          liveAgainstUser:
              state.liveAgainstUser.where((r) => r.id != reportId).toList(),
          solvedAgainstUser: [...state.solvedAgainstUser, updatedReport],
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to mark report as solved: ${e.toString()}',
      );
    }
  }

  // Update a specific report
  void updateReport(Report updatedReport) {
    try {
      state = state.copyWith(
        liveByUser:
            state.liveByUser
                .map((r) => r.id == updatedReport.id ? updatedReport : r)
                .toList(),
        liveAgainstUser:
            state.liveAgainstUser
                .map((r) => r.id == updatedReport.id ? updatedReport : r)
                .toList(),
        solvedByUser:
            state.solvedByUser
                .map((r) => r.id == updatedReport.id ? updatedReport : r)
                .toList(),
        solvedAgainstUser:
            state.solvedAgainstUser
                .map((r) => r.id == updatedReport.id ? updatedReport : r)
                .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update report: ${e.toString()}');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset state
  void resetState() {
    state = const ReportsState();
  }

  String _getErrorMessage(dynamic error) {
    if (error is ConnectivityException) {
      return 'No internet connection. Please check your network.';
    } else if (error is AuthException) {
      return 'Authentication error. Please login again.';
    } else if (error is ApiException) {
      return 'Server error. Please try again later.';
    } else if (error is FormatException) {
      return 'Data format error. Please contact support.';
    } else if (error is TimeoutException) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}

// Computed providers for widget formatting
@riverpod
List<Map<String, dynamic>> liveReportsByUserFormatted(
  LiveReportsByUserFormattedRef ref,
) {
  final reports = ref.watch(reportsProvider).liveByUser;
  return reports.map((report) {
    try {
      return report.toWidgetFormat();
    } catch (e) {
      // Return a safe fallback if formatting fails
      return {
        'timeDate': 'Unknown Time',
        'status': 'Unknown',
        'location': 'Unknown Location',
        'message': 'Error loading report',
        'reporter': 'Unknown',
        'profileImage': null,
        'latitude': null,
        'longitude': null,
      };
    }
  }).toList();
}

@riverpod
List<Map<String, dynamic>> liveReportsAgainstUserFormatted(
  LiveReportsAgainstUserFormattedRef ref,
) {
  final reports = ref.watch(reportsProvider).liveAgainstUser;
  return reports.map((report) {
    try {
      return report.toWidgetFormat();
    } catch (e) {
      return {
        'timeDate': 'Unknown Time',
        'status': 'Unknown',
        'location': 'Unknown Location',
        'message': 'Error loading report',
        'reporter': 'Unknown',
        'profileImage': null,
        'latitude': null,
        'longitude': null,
      };
    }
  }).toList();
}

@riverpod
List<Map<String, dynamic>> solvedReportsByUserFormatted(
  SolvedReportsByUserFormattedRef ref,
) {
  final reports = ref.watch(reportsProvider).solvedByUser;
  return reports.map((report) {
    try {
      return report.toWidgetFormat();
    } catch (e) {
      return {
        'timeDate': 'Unknown Time',
        'status': 'Unknown',
        'location': 'Unknown Location',
        'message': 'Error loading report',
        'reporter': 'Unknown',
        'profileImage': null,
        'latitude': null,
        'longitude': null,
      };
    }
  }).toList();
}

@riverpod
List<Map<String, dynamic>> solvedReportsAgainstUserFormatted(
  SolvedReportsAgainstUserFormattedRef ref,
) {
  final reports = ref.watch(reportsProvider).solvedAgainstUser;
  return reports.map((report) {
    try {
      return report.toWidgetFormat();
    } catch (e) {
      return {
        'timeDate': 'Unknown Time',
        'status': 'Unknown',
        'location': 'Unknown Location',
        'message': 'Error loading report',
        'reporter': 'Unknown',
        'profileImage': null,
        'latitude': null,
        'longitude': null,
      };
    }
  }).toList();
}

// Cache provider for better performance
@riverpod
class ReportsCache extends _$ReportsCache {
  @override
  DateTime? build() => null;

  void updateCacheTime() {
    state = DateTime.now();
  }

  void clearCache() {
    state = null;
  }

  bool get isCacheValid {
    if (state == null) return false;
    return DateTime.now().difference(state!).inMinutes < 5; // 5 minutes cache
  }

  int get cacheAgeInMinutes {
    if (state == null) return -1;
    return DateTime.now().difference(state!).inMinutes;
  }
}

// Additional utility providers
@riverpod
int totalReportsCount(TotalReportsCountRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.totalReports;
}

@riverpod
bool hasAnyReports(HasAnyReportsRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return !reportsState.hasNoReports;
}

@riverpod
List<Report> allReports(AllReportsRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return [
    ...reportsState.liveByUser,
    ...reportsState.liveAgainstUser,
    ...reportsState.solvedByUser,
    ...reportsState.solvedAgainstUser,
  ];
}
