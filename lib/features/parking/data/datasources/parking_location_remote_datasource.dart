// lib/features/parking/data/datasources/parking_location_remote_datasource.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letmegoo/models/parking_location_model.dart';
import 'package:letmegoo/core/utils/logger.dart';

class ParkingLocationRemoteDataSource {
  static const String baseUrl = 'https://api.letmegoo.com/api';
  static const Duration timeoutDuration = Duration(seconds: 30);
  static final http.Client _client = http.Client();

  /// Get authentication headers
  static Future<Map<String, String>> _getAuthHeaders({
    String contentType = 'application/json',
  }) async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not authenticated');
    }

    final String? idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get authentication token');
    }

    return {'Authorization': 'Bearer $idToken', 'Content-Type': contentType};
  }

  /// Create a new parking location
  static Future<ParkingLocation> createParkingLocation(
    ParkingLocationRequest request,
  ) async {
    try {
      final headers = await _getAuthHeaders(contentType: 'multipart/form-data');
      headers.remove('Content-Type'); // Let http package set boundary

      final uri = Uri.parse('$baseUrl/vehicle/location/add');
      final multipartRequest = http.MultipartRequest('POST', uri);

      // Add headers
      multipartRequest.headers.addAll({
        'Authorization': headers['Authorization']!,
      });

      // Add form fields
      multipartRequest.fields.addAll({
        'vehicle_number': request.vehicleNumber,
        'latitude': request.latitude.toString(),
        'longitude': request.longitude.toString(),
        'visibility': request.visibility,
      });

      if (request.notes != null && request.notes!.isNotEmpty) {
        multipartRequest.fields['notes'] = request.notes!;
      }

      // Add image file if provided
      if (request.imagePath != null && request.imagePath!.isNotEmpty) {
        final file = File(request.imagePath!);
        if (await file.exists()) {
          multipartRequest.files.add(
            await http.MultipartFile.fromPath('image', request.imagePath!),
          );
        }
      }

      AppLogger.debug('🚗 Creating parking location for vehicle: ${request.vehicleNumber}',);
      AppLogger.debug('📍 Location: ${request.latitude}, ${request.longitude}');
      AppLogger.debug('👁️ Visibility: ${request.visibility}');
      if (request.notes != null) {
        AppLogger.debug('📝 Notes: ${request.notes}');
      }

      final streamedResponse = await multipartRequest.send().timeout(
        timeoutDuration,
      );
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.debug('📤 Response status: ${response.statusCode}');
      AppLogger.debug('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ParkingLocation.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to create parking location: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      AppLogger.debug('❌ Error creating parking location: $e');
      rethrow;
    }
  }

  /// Get list of parking locations
  static Future<ParkingLocationListResponse> getParkingLocations({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final uri = Uri.parse('$baseUrl/vehicle/location/list').replace(
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      AppLogger.debug('🔍 Fetching parking locations...');
      AppLogger.debug('📄 Limit: $limit, Offset: $offset');

      final response = await _client
          .get(uri, headers: headers)
          .timeout(timeoutDuration);

      AppLogger.debug('📤 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final locationResponse = ParkingLocationListResponse.fromJson(
          responseData,
        );

        AppLogger.debug('✅ Fetched ${locationResponse.items.length} parking locations');
        AppLogger.debug('📊 Has more: ${locationResponse.hasMore}');

        return locationResponse;
      } else {
        throw Exception(
          'Failed to fetch parking locations: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      AppLogger.debug('❌ Error fetching parking locations: $e');
      rethrow;
    }
  }

  /// Delete a parking location
  static Future<bool> deleteParkingLocation(String locationId) async {
    try {
      final headers = await _getAuthHeaders();

      final uri = Uri.parse('$baseUrl/vehicle/location/delete/$locationId');

      AppLogger.debug('🗑️ Deleting parking location: $locationId');

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(timeoutDuration);

      AppLogger.debug('📤 Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.debug('✅ Parking location deleted successfully');
        return true;
      } else {
        AppLogger.debug('❌ Failed to delete: ${response.statusCode} - ${response.body}');
        return false;
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      AppLogger.debug('❌ Error deleting parking location: $e');
      return false;
    }
  }

  /// Update a parking location
  static Future<ParkingLocation?> updateParkingLocation(
    String locationId,
    ParkingLocationRequest request,
  ) async {
    try {
      final headers = await _getAuthHeaders(contentType: 'multipart/form-data');
      headers.remove('Content-Type'); // Let http package set boundary

      final uri = Uri.parse('$baseUrl/vehicle/location/$locationId');
      final multipartRequest = http.MultipartRequest('PUT', uri);

      // Add headers
      multipartRequest.headers.addAll({
        'Authorization': headers['Authorization']!,
      });

      // Add form fields
      multipartRequest.fields.addAll({
        'vehicle_number': request.vehicleNumber,
        'latitude': request.latitude.toString(),
        'longitude': request.longitude.toString(),
        'visibility': request.visibility,
      });

      if (request.notes != null && request.notes!.isNotEmpty) {
        multipartRequest.fields['notes'] = request.notes!;
      }

      // Add image file if provided
      if (request.imagePath != null && request.imagePath!.isNotEmpty) {
        final file = File(request.imagePath!);
        if (await file.exists()) {
          multipartRequest.files.add(
            await http.MultipartFile.fromPath('image', request.imagePath!),
          );
        }
      }

      AppLogger.debug('📝 Updating parking location: $locationId');

      final streamedResponse = await multipartRequest.send().timeout(
        timeoutDuration,
      );
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.debug('📤 Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ParkingLocation.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to update parking location: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      AppLogger.debug('❌ Error updating parking location: $e');
      rethrow;
    }
  }

  /// Dispose HTTP client
  static void dispose() {
    _client.close();
  }
}
