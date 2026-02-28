import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:letmegoo/features/report/domain/entities/report.dart';
import 'package:letmegoo/features/report/domain/repositories/report_repository.dart';
import 'package:letmegoo/features/report/domain/usecases/get_all_reports.dart';
import 'package:letmegoo/features/report/domain/usecases/create_report.dart';
import 'package:letmegoo/features/report/domain/usecases/mark_report_solved.dart';
import 'package:letmegoo/features/report/domain/usecases/flag_report.dart';
import 'package:letmegoo/features/report/data/datasources/report_remote_datasource.dart';
import 'package:letmegoo/features/report/data/repositories/report_repository_impl.dart';

part 'report_provider.g.dart';

// ============================================================================
// Dependency Injection Providers
// ============================================================================

/// Provider for ReportRemoteDataSource
@riverpod
ReportRemoteDataSource reportRemoteDataSource(ReportRemoteDataSourceRef ref) {
  return ReportRemoteDataSource();
}

/// Provider for ReportRepository
@riverpod
ReportRepository reportRepository(ReportRepositoryRef ref) {
  final remoteDataSource = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(remoteDataSource: remoteDataSource);
}

/// Provider for GetAllReports use case
@riverpod
GetAllReports getAllReportsUseCase(GetAllReportsUseCaseRef ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GetAllReports(repository);
}

/// Provider for CreateReport use case
@riverpod
CreateReport createReportUseCase(CreateReportUseCaseRef ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return CreateReport(repository);
}

/// Provider for MarkReportAsSolved use case
@riverpod
MarkReportAsSolved markReportAsSolvedUseCase(MarkReportAsSolvedUseCaseRef ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return MarkReportAsSolved(repository);
}

/// Provider for FlagReport use case
@riverpod
FlagReport flagReportUseCase(FlagReportUseCaseRef ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return FlagReport(repository);
}

// ============================================================================
// State Classes
// ============================================================================

/// State for reports
class ReportsState {
  final List<Report> reportsByUser;
  final List<Report> reportsAgainstUser;
  final bool isLoading;
  final String? error;

  const ReportsState({
    this.reportsByUser = const [],
    this.reportsAgainstUser = const [],
    this.isLoading = false,
    this.error,
  });

  ReportsState copyWith({
    List<Report>? reportsByUser,
    List<Report>? reportsAgainstUser,
    bool? isLoading,
    String? error,
  }) {
    return ReportsState(
      reportsByUser: reportsByUser ?? this.reportsByUser,
      reportsAgainstUser: reportsAgainstUser ?? this.reportsAgainstUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get live (not closed) reports by user
  List<Report> get liveReportsByUser =>
      reportsByUser.where((r) => !r.isClosed).toList();

  /// Get solved (closed) reports by user
  List<Report> get solvedReportsByUser =>
      reportsByUser.where((r) => r.isClosed).toList();

  /// Get live reports against user
  List<Report> get liveReportsAgainstUser =>
      reportsAgainstUser.where((r) => !r.isClosed).toList();

  /// Get solved reports against user
  List<Report> get solvedReportsAgainstUser =>
      reportsAgainstUser.where((r) => r.isClosed).toList();

  // Backward compatibility aliases for old API
  List<Report> get liveByUser => liveReportsByUser;
  List<Report> get liveAgainstUser => liveReportsAgainstUser;
  List<Report> get solvedByUser => solvedReportsByUser;
  List<Report> get solvedAgainstUser => solvedReportsAgainstUser;

  /// Total count of all reports
  int get totalReports => reportsByUser.length + reportsAgainstUser.length;

  /// Check if there are no reports at all
  bool get hasNoReports => totalReports == 0;
}

// ============================================================================
// Main Reports Notifier
// ============================================================================

/// Main provider for reports management
@riverpod
class Reports extends _$Reports {
  @override
  ReportsState build() {
    // Auto-load reports on initialization
    loadReports();
    return const ReportsState();
  }

  /// Load all reports
  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(reportRepositoryProvider);

      // Load both types of reports in parallel
      final results = await Future.wait([
        repository.getReportsByUser(),
        repository.getReportsAgainstUser(),
      ]);

      state = state.copyWith(
        reportsByUser: results[0],
        reportsAgainstUser: results[1],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new report
  Future<Report?> createReport({
    required String vehicleNumber,
    required String notes,
    required String latitude,
    required String longitude,
    String? location,
    List<String>? imagePaths,
    bool isAnonymous = false,
  }) async {
    try {
      final useCase = ref.read(createReportUseCaseProvider);
      final params = CreateReportParams(
        vehicleNumber: vehicleNumber,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        location: location,
        imagePaths: imagePaths,
        isAnonymous: isAnonymous,
      );

      final report = await useCase(params);

      // Refresh reports after creation
      await loadReports();

      return report;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Mark report as solved
  Future<bool> markReportAsSolved(String reportId) async {
    try {
      final useCase = ref.read(markReportAsSolvedUseCaseProvider);
      final params = MarkReportAsSolvedParams(reportId: reportId);

      await useCase(params);

      // Refresh reports
      await loadReports();

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Flag a report
  Future<bool> flagReport(String reportId) async {
    try {
      final useCase = ref.read(flagReportUseCaseProvider);
      final params = FlagReportParams(reportId: reportId);

      final success = await useCase(params);
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Refresh reports
  Future<void> refresh() async {
    final repository = ref.read(reportRepositoryProvider);
    repository.clearCache();
    await loadReports();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// Convenience Providers
// ============================================================================

/// Provider for live reports by user
@riverpod
List<Report> liveReportsByUser(LiveReportsByUserRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.liveReportsByUser;
}

/// Provider for solved reports by user
@riverpod
List<Report> solvedReportsByUser(SolvedReportsByUserRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.solvedReportsByUser;
}

/// Provider for live reports against user
@riverpod
List<Report> liveReportsAgainstUser(LiveReportsAgainstUserRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.liveReportsAgainstUser;
}

/// Provider for solved reports against user
@riverpod
List<Report> solvedReportsAgainstUser(SolvedReportsAgainstUserRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.solvedReportsAgainstUser;
}

/// Provider for reports loading state
@riverpod
bool reportsLoading(ReportsLoadingRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.isLoading;
}

/// Provider for reports error
@riverpod
String? reportsError(ReportsErrorRef ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.error;
}

// ============================================================================
// Formatted Providers (for backward compatibility)
// ============================================================================

/// Helper: Convert a Report entity to the Map format expected by buildReportSection
Map<String, dynamic> _formatReport(Report report) {
  // Format the date/time
  final created = report.createdAt;
  final timeDate =
      '${created.day}/${created.month}/${created.year} ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

  // Get the first available image
  String? firstImage;
  bool hasImages = report.images.isNotEmpty;
  if (hasImages) {
    firstImage = report.images.first.bestImage;
  }

  // Collect all image URLs
  final imageUrls =
      report.images
          .map((img) => img.bestImage)
          .where((url) => url != null)
          .cast<String>()
          .toList();

  return {
    'reportId': report.id,
    'reportNumber': report.reportNumber,
    'timeDate': timeDate,
    'status': report.currentStatus.toDisplayString(),
    'location': report.location ?? 'Unknown Location',
    'message': report.notes,
    'reporter': report.reporter.displayName,
    'profileImage': report.reporter.profilePicture,
    'latitude': report.latitude,
    'longitude': report.longitude,
    'images': imageUrls,
    'hasImages': hasImages,
    'firstImage': firstImage,
    'vehicleNumber': report.vehicle.vehicleNumber,
    'vehicleType': report.vehicle.vehicleType,
    'isClosed': report.isClosed,
    'isAnonymous': report.isAnonymous,
  };
}

/// Provider for live reports by user formatted as Map
@riverpod
List<Map<String, dynamic>> liveReportsByUserFormatted(
  LiveReportsByUserFormattedRef ref,
) {
  final reports = ref.watch(liveReportsByUserProvider);
  return reports.map(_formatReport).toList();
}

/// Provider for live reports against user formatted as Map
@riverpod
List<Map<String, dynamic>> liveReportsAgainstUserFormatted(
  LiveReportsAgainstUserFormattedRef ref,
) {
  final reports = ref.watch(liveReportsAgainstUserProvider);
  return reports.map(_formatReport).toList();
}

/// Provider for solved reports by user formatted as Map
@riverpod
List<Map<String, dynamic>> solvedReportsByUserFormatted(
  SolvedReportsByUserFormattedRef ref,
) {
  final reports = ref.watch(solvedReportsByUserProvider);
  return reports.map(_formatReport).toList();
}

/// Provider for solved reports against user formatted as Map
@riverpod
List<Map<String, dynamic>> solvedReportsAgainstUserFormatted(
  SolvedReportsAgainstUserFormattedRef ref,
) {
  final reports = ref.watch(solvedReportsAgainstUserProvider);
  return reports.map(_formatReport).toList();
}
