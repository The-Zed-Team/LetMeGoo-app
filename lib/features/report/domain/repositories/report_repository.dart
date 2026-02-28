import 'package:letmegoo/features/report/domain/entities/report.dart';

/// Abstract repository interface for report operations
abstract class ReportRepository {
  /// Get all reports (by and against current user)
  Future<List<Report>> getAllReports();

  /// Get reports created by current user
  Future<List<Report>> getReportsByUser();

  /// Get reports against current user's vehicles
  Future<List<Report>> getReportsAgainstUser();

  /// Get a specific report by ID
  Future<Report> getReportById(String reportId);

  /// Create a new report
  Future<Report> createReport({
    required String vehicleNumber,
    required String notes,
    required String latitude,
    required String longitude,
    String? location,
    List<String>? imagePaths,
    bool isAnonymous = false,
  });

  /// Update report status
  Future<Report> updateReportStatus({
    required String reportId,
    required String status,
  });

  /// Mark report as solved
  Future<Report> markReportAsSolved(String reportId);

  /// Flag a report
  Future<bool> flagReport(String reportId);

  /// Stream of live reports (not closed)
  Stream<List<Report>> watchLiveReportsByUser();

  /// Stream of live reports against user
  Stream<List<Report>> watchLiveReportsAgainstUser();

  /// Stream of solved reports by user
  Stream<List<Report>> watchSolvedReportsByUser();

  /// Stream of solved reports against user
  Stream<List<Report>> watchSolvedReportsAgainstUser();

  /// Clear cached reports
  void clearCache();
}
