import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:letmegoo/core/error/exceptions.dart';
import 'package:letmegoo/core/network/api_client.dart';
import 'package:letmegoo/features/shop/data/models/shop_dto.dart';

/// Remote datasource for shop operations
class ShopRemoteDataSource {
  static String get _baseUrl => ApiClient.baseUrl;
  static final http.Client _httpClient = http.Client();

  /// Get paginated list of shops
  Future<ShopListResponseDto> getShops({int offset = 0, int limit = 50}) async {
    try {
      final uri = Uri.parse('$_baseUrl/shop/list').replace(
        queryParameters: {
          'offset': offset.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await _httpClient
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ShopListResponseDto.fromJson(jsonData);
      } else {
        throw _handleHttpError(response);
      }
    } on SocketException {
      throw const NetworkException();
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to fetch shops: $e');
    }
  }

  /// Handle HTTP error responses
  Exception _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return const ValidationException(message: 'Invalid request');
      case 401:
        return const AuthException(message: 'Unauthorized');
      case 404:
        return const NotFoundException(message: 'Resource not found');
      case >= 500:
        return ServerException(
          message: 'Server error',
          statusCode: response.statusCode,
        );
      default:
        return ServerException(
          message: 'Request failed',
          statusCode: response.statusCode,
        );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
