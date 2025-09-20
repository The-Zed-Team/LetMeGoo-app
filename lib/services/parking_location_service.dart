// lib/services/parking_location_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letmegoo/models/parking_location_model.dart';

class ParkingLocationService {
  static const String baseUrl = 'https://api.letmegoo.com/api';
  static const Duration timeoutDuration = Duration(seconds: 30);
  static final http.Client _httpClient = http.Client();

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

      print(
        '🚗 Creating parking location for vehicle: ${request.vehicleNumber}',
      );
      print('📍 Location: ${request.latitude}, ${request.longitude}');
      print('👁️ Visibility: ${request.visibility}');
      if (request.notes != null) {
        print('📝 Notes: ${request.notes}');
      }

      final streamedResponse = await multipartRequest.send().timeout(
        timeoutDuration,
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

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
      print('❌ Error creating parking location: $e');
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

      print('🔍 Fetching parking locations...');
      print('📄 Limit: $limit, Offset: $offset');

      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(timeoutDuration);

      print('📤 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final locationResponse = ParkingLocationListResponse.fromJson(
          responseData,
        );

        print('✅ Fetched ${locationResponse.items.length} parking locations');
        print('📊 Has more: ${locationResponse.hasMore}');

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
      print('❌ Error fetching parking locations: $e');
      rethrow;
    }
  }

  /// Delete a parking location
  static Future<bool> deleteParkingLocation(String locationId) async {
    try {
      final headers = await _getAuthHeaders();

      final uri = Uri.parse('$baseUrl/vehicle/location/delete/$locationId');

      print('🗑️ Deleting parking location: $locationId');

      final response = await _httpClient
          .delete(uri, headers: headers)
          .timeout(timeoutDuration);

      print('📤 Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Parking location deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete: ${response.statusCode} - ${response.body}');
        return false;
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      print('❌ Error deleting parking location: $e');
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

      print('📝 Updating parking location: $locationId');

      final streamedResponse = await multipartRequest.send().timeout(
        timeoutDuration,
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 Update response status: ${response.statusCode}');

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
      print('❌ Error updating parking location: $e');
      rethrow;
    }
  }

  /// Check if user has internet connection
  static Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Dispose HTTP client
  static void dispose() {
    _httpClient.close();
  }
}
