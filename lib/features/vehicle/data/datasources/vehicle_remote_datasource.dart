import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:letmegoo/core/network/api_client.dart';
import 'package:letmegoo/core/error/exceptions.dart';
import 'package:letmegoo/features/vehicle/data/models/vehicle_dto.dart';

/// Remote data source for vehicle operations
class VehicleRemoteDataSource {
  /// Parse a list of items from an API response that could be either
  /// a direct List or a Map with common wrapper keys.
  static List<Map<String, dynamic>> _parseListResponse(dynamic response) {
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    } else if (response is Map<String, dynamic>) {
      final possibleKeys = ['vehicles', 'data', 'results', 'items'];
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

  /// Get all user vehicles
  Future<List<VehicleDto>> getUserVehicles() async {
    try {
      final response = await ApiClient.get('/vehicle/list');
      final items = _parseListResponse(response);
      return items.map((v) => VehicleDto.fromJson(v)).toList();
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get vehicles: $e');
    }
  }

  /// Get vehicle by ID
  Future<VehicleDto> getVehicleById(String vehicleId) async {
    try {
      final response = await ApiClient.get('/vehicle/get/$vehicleId');
      if (response is Map<String, dynamic>) {
        return VehicleDto.fromJson(response);
      }
      throw const ServerException(message: 'Invalid vehicle response format');
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get vehicle: $e');
    }
  }

  /// Create a new vehicle
  Future<VehicleDto> createVehicle({
    required String vehicleNumber,
    required String vehicleType,
    String? name,
    String? brand,
    String? fuelType,
    File? image,
  }) async {
    try {
      final fields = {
        'vehicle_number': vehicleNumber,
        'vehicle_type': vehicleType,
        if (name != null) 'name': name,
        if (brand != null) 'brand': brand,
        if (fuelType != null) 'fuel_type': fuelType,
      };

      // Always use multipart - the server expects multipart/form-data
      List<http.MultipartFile>? files;
      if (image != null) {
        final file = await ApiClient.createMultipartFile('image', image);
        files = [file];
      }

      final response = await ApiClient.multipartPost(
        '/vehicle/create',
        fields: fields,
        files: files,
      );
      return VehicleDto.fromJson(response);
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to create vehicle: $e');
    }
  }

  /// Update a vehicle
  Future<VehicleDto> updateVehicle({
    required String vehicleId,
    required String vehicleNumber,
    required String vehicleType,
    String? name,
    String? brand,
    String? fuelType,
    File? image,
  }) async {
    try {
      final fields = {
        'vehicle_number': vehicleNumber,
        'vehicle_type': vehicleType,
        if (name != null) 'name': name,
        if (brand != null) 'brand': brand,
        if (fuelType != null) 'fuel_type': fuelType,
      };

      // Always use multipart - the server expects multipart/form-data
      List<http.MultipartFile>? files;
      if (image != null) {
        final file = await ApiClient.createMultipartFile('image', image);
        files = [file];
      }

      final response = await ApiClient.multipartPost(
        '/vehicle/update/$vehicleId',
        fields: fields,
        files: files,
      );
      return VehicleDto.fromJson(response);
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update vehicle: $e');
    }
  }

  /// Delete a vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await ApiClient.delete('/vehicle/delete/$vehicleId');
      return true;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to delete vehicle: $e');
    }
  }

  /// Search vehicles
  Future<List<VehicleDto>> searchVehicles(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, String>{
        'vehicle_number': query.trim(),
        'limit': '10',
        'offset': '0',
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await ApiClient.get(
        '/vehicle/search',
        queryParams: queryParams,
      );

      final items = _parseListResponse(response);
      return items.map((v) => VehicleDto.fromJson(v)).toList();
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to search vehicles: $e');
    }
  }

  /// Get available vehicle types
  Future<List<VehicleTypeInfoDto>> getVehicleTypes() async {
    try {
      final response = await ApiClient.get('/vehicle/types');

      // Check for list response - could also be in 'types' key
      if (response is List) {
        return response
            .whereType<Map<String, dynamic>>()
            .map((v) => VehicleTypeInfoDto.fromJson(v))
            .toList();
      } else if (response is Map<String, dynamic>) {
        final possibleKeys = ['types', 'data', 'results', 'items'];
        for (final key in possibleKeys) {
          if (response[key] is List) {
            return (response[key] as List)
                .whereType<Map<String, dynamic>>()
                .map((v) => VehicleTypeInfoDto.fromJson(v))
                .toList();
          }
        }
      }
      return [];
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get vehicle types: $e');
    }
  }
}
