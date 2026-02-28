import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:letmegoo/core/network/api_client.dart';
import 'package:letmegoo/core/error/exceptions.dart';
import 'package:letmegoo/features/report/data/models/report_dto.dart';
import 'package:letmegoo/models/report_request.dart';

/// Remote data source for report operations
class ReportRemoteDataSource {
  /// Parse a list of items from an API response that could be either
  /// a direct List or a Map with common wrapper keys.
  static List<Map<String, dynamic>> _parseListResponse(dynamic response) {
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    } else if (response is Map<String, dynamic>) {
      final possibleKeys = ['reports', 'data', 'results', 'items'];
      for (final key in possibleKeys) {
        if (response[key] is List) {
          return (response[key] as List)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }
    }
    return [];
  }

  /// Get all reports
  Future<List<ReportDto>> getAllReports() async {
    try {
      final response = await ApiClient.get('/vehicle/report/list');
      final items = _parseListResponse(response);
      return items.map((r) => ReportDto.fromJson(r)).toList();
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get reports: $e');
    }
  }

  /// Get reports by current user (both live and solved)
  Future<List<ReportDto>> getReportsByUser() async {
    try {
      // Fetch both live and solved reports by user
      final liveResponse = await ApiClient.get(
        '/vehicle/report/list',
        queryParams: {'is_closed': 'false', 'type': 'reported_by_me'},
      );
      final solvedResponse = await ApiClient.get(
        '/vehicle/report/list',
        queryParams: {'is_closed': 'true', 'type': 'reported_by_me'},
      );

      final reports = <ReportDto>[];
      reports.addAll(
        _parseListResponse(liveResponse).map((r) => ReportDto.fromJson(r)),
      );
      reports.addAll(
        _parseListResponse(solvedResponse).map((r) => ReportDto.fromJson(r)),
      );
      return reports;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get user reports: $e');
    }
  }

  /// Get reports against user's vehicles (both live and solved)
  Future<List<ReportDto>> getReportsAgainstUser() async {
    try {
      // Fetch both live and solved reports against user
      final liveResponse = await ApiClient.get(
        '/vehicle/report/list',
        queryParams: {'is_closed': 'false', 'type': 'reported_to_me'},
      );
      final solvedResponse = await ApiClient.get(
        '/vehicle/report/list',
        queryParams: {'is_closed': 'true', 'type': 'reported_to_me'},
      );

      final reports = <ReportDto>[];
      reports.addAll(
        _parseListResponse(liveResponse).map((r) => ReportDto.fromJson(r)),
      );
      reports.addAll(
        _parseListResponse(solvedResponse).map((r) => ReportDto.fromJson(r)),
      );
      return reports;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get reports against user: $e');
    }
  }

  /// Get report by ID
  Future<ReportDto> getReportById(String reportId) async {
    try {
      final response = await ApiClient.get('/vehicle/report/get/$reportId');
      if (response is Map<String, dynamic>) {
        return ReportDto.fromJson(response);
      }
      throw const ServerException(message: 'Invalid report response format');
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get report: $e');
    }
  }

  /// Create a new report
  Future<ReportDto> createReport({
    required String vehicleNumber,
    required String notes,
    required String latitude,
    required String longitude,
    String? location,
    List<String>? imagePaths,
    bool isAnonymous = false,
  }) async {
    try {
      final fields = {
        'vehicle_number': vehicleNumber,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
        'is_anonymous': isAnonymous.toString(),
        if (location != null) 'location': location,
      };

      if (imagePaths != null && imagePaths.isNotEmpty) {
        final files = await Future.wait(
          imagePaths.map(
            (path) => ApiClient.createMultipartFile('images', File(path)),
          ),
        );
        final response = await ApiClient.multipartPost(
          '/vehicle/report/',
          fields: fields,
          files: files,
        );
        return ReportDto.fromJson(response);
      } else {
        final response = await ApiClient.post('/vehicle/report/', body: fields);
        if (response is Map<String, dynamic>) {
          return ReportDto.fromJson(response);
        }
        throw const ServerException(
          message: 'Invalid response from create report',
        );
      }
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to create report: $e');
    }
  }

  /// Update report status
  Future<ReportDto> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    try {
      final response = await ApiClient.patch(
        '/vehicle/report/$reportId/update_status/',
        body: {'status': status},
      );
      if (response is Map<String, dynamic>) {
        return ReportDto.fromJson(response);
      }
      throw const ServerException(message: 'Invalid status update response');
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update report status: $e');
    }
  }

  /// Mark report as solved
  Future<ReportDto> markReportAsSolved(String reportId) async {
    try {
      final response = await ApiClient.post(
        '/vehicle/report/$reportId/mark_solved/',
      );
      if (response is Map<String, dynamic>) {
        return ReportDto.fromJson(response);
      }
      throw const ServerException(message: 'Invalid mark solved response');
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to mark report as solved: $e');
    }
  }

  /// Flag a report
  Future<bool> flagReport(String reportId) async {
    try {
      await ApiClient.post('/vehicle/report/$reportId/flag/');
      return true;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to flag report: $e');
    }
  }

  /// Report a vehicle (wrapper around multipart POST for backwards compatibility)
  Future<Map<String, dynamic>> reportVehicle(ReportRequest request) async {
    try {
      // Use the ReportRequest's toFormData() for correct field names
      final fields = request.toFormData();

      // Build multipart files from images
      List<http.MultipartFile>? files;
      if (request.images.isNotEmpty) {
        files = [];
        for (final image in request.images) {
          if (await image.exists()) {
            final file = await ApiClient.createMultipartFile('images', image);
            files.add(file);
          }
        }
      }

      // Always use multipart POST (matching old auth_service behavior)
      final response = await ApiClient.multipartPost(
        '/vehicle/report/',
        fields: fields,
        files: files,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Search for vehicles (used in create report flow)
  Future<List<Map<String, dynamic>>> searchVehicles(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, String>{
        'vehicle_number': query.trim(),
        'limit': '10',
        'offset': '0',
      };
      if (latitude != null) {
        queryParams['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude.toString();
      }

      final response = await ApiClient.get(
        '/vehicle/search',
        queryParams: queryParams,
      );

      // Parse response - could be List or Map with common keys
      final items = _parseListResponse(response);
      return items;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Vehicle search failed: $e');
    }
  }
}
