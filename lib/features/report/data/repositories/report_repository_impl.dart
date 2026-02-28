import 'dart:async';
import 'package:letmegoo/features/report/domain/entities/report.dart';
import 'package:letmegoo/features/report/domain/repositories/report_repository.dart';
import 'package:letmegoo/features/report/data/datasources/report_remote_datasource.dart';

/// Implementation of ReportRepository
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  // Cache for reports
  List<Report>? _cachedReports;
  final _reportsController = StreamController<List<Report>>.broadcast();

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Report>> getAllReports() async {
    try {
      final reportDtos = await remoteDataSource.getAllReports();
      _cachedReports = reportDtos.map((dto) => dto.toEntity()).toList();
      _reportsController.add(_cachedReports!);
      return _cachedReports!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Report>> getReportsByUser() async {
    try {
      final reportDtos = await remoteDataSource.getReportsByUser();
      final reports = reportDtos.map((dto) => dto.toEntity()).toList();
      return reports;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Report>> getReportsAgainstUser() async {
    try {
      final reportDtos = await remoteDataSource.getReportsAgainstUser();
      final reports = reportDtos.map((dto) => dto.toEntity()).toList();
      return reports;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Report> getReportById(String reportId) async {
    try {
      final reportDto = await remoteDataSource.getReportById(reportId);
      return reportDto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Report> createReport({
    required String vehicleNumber,
    required String notes,
    required String latitude,
    required String longitude,
    String? location,
    List<String>? imagePaths,
    bool isAnonymous = false,
  }) async {
    try {
      final reportDto = await remoteDataSource.createReport(
        vehicleNumber: vehicleNumber,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        location: location,
        imagePaths: imagePaths,
        isAnonymous: isAnonymous,
      );

      // Refresh cached reports
      clearCache();

      return reportDto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Report> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    try {
      final reportDto = await remoteDataSource.updateReportStatus(
        reportId: reportId,
        status: status,
      );

      // Refresh cached reports
      clearCache();

      return reportDto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Report> markReportAsSolved(String reportId) async {
    try {
      final reportDto = await remoteDataSource.markReportAsSolved(reportId);

      // Refresh cached reports
      clearCache();

      return reportDto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> flagReport(String reportId) async {
    try {
      return await remoteDataSource.flagReport(reportId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<Report>> watchLiveReportsByUser() async* {
    while (true) {
      try {
        final reports = await getReportsByUser();
        final liveReports = reports.where((r) => !r.isClosed).toList();
        yield liveReports;
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        yield [];
      }
    }
  }

  @override
  Stream<List<Report>> watchLiveReportsAgainstUser() async* {
    while (true) {
      try {
        final reports = await getReportsAgainstUser();
        final liveReports = reports.where((r) => !r.isClosed).toList();
        yield liveReports;
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        yield [];
      }
    }
  }

  @override
  Stream<List<Report>> watchSolvedReportsByUser() async* {
    while (true) {
      try {
        final reports = await getReportsByUser();
        final solvedReports = reports.where((r) => r.isClosed).toList();
        yield solvedReports;
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        yield [];
      }
    }
  }

  @override
  Stream<List<Report>> watchSolvedReportsAgainstUser() async* {
    while (true) {
      try {
        final reports = await getReportsAgainstUser();
        final solvedReports = reports.where((r) => r.isClosed).toList();
        yield solvedReports;
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        yield [];
      }
    }
  }

  @override
  void clearCache() {
    _cachedReports = null;
  }

  void dispose() {
    _reportsController.close();
  }
}
