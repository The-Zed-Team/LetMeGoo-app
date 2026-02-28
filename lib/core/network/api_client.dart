import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:letmegoo/core/error/exceptions.dart';

/// Centralized API client for making HTTP requests
///
/// Handles authentication headers, error responses, and common HTTP operations.
class ApiClient {
  static const String _baseUrl = 'https://api.letmegoo.com/api';
  static final http.Client _httpClient = http.Client();

  /// Get authenticated headers with Firebase JWT token
  static Future<Map<String, String>> getAuthHeaders({
    String contentType = 'application/json',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const AuthException(message: 'No authenticated user found');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null) {
      throw const AuthException(message: 'Failed to get authentication token');
    }

    return {
      'Authorization': 'Bearer $idToken',
      'Content-Type': contentType,
      'Accept': 'application/json',
    };
  }

  /// Handle HTTP response errors
  static void handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw const AuthException(message: 'Unauthorized - please login again');
      case 403:
        throw const ForbiddenException(message: 'Access denied');
      case 404:
        throw const NotFoundException(message: 'Resource not found');
      case 422:
        final body = json.decode(response.body);
        throw ValidationException(
          message: body['detail'] ?? 'Validation error',
        );
      case >= 500:
        throw ServerException(
          message: 'Server error occurred',
          statusCode: response.statusCode,
        );
      default:
        if (response.statusCode >= 400) {
          throw ServerException(
            message: 'Request failed',
            statusCode: response.statusCode,
          );
        }
    }
  }

  /// GET request
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await getAuthHeaders();
      var uri = Uri.parse('$_baseUrl$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _httpClient.get(uri, headers: headers);

      if (response.statusCode >= 400) {
        handleHttpError(response);
      }

      return json.decode(response.body);
    } on SocketException {
      throw const NetworkException();
    }
  }

  /// POST request
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode >= 400) {
        handleHttpError(response);
      }

      return json.decode(response.body);
    } on SocketException {
      throw const NetworkException();
    }
  }

  /// PUT request
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _httpClient.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode >= 400) {
        handleHttpError(response);
      }

      return json.decode(response.body);
    } on SocketException {
      throw const NetworkException();
    }
  }

  /// PATCH request
  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _httpClient.patch(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode >= 400) {
        handleHttpError(response);
      }

      return json.decode(response.body);
    } on SocketException {
      throw const NetworkException();
    }
  }

  /// DELETE request
  static Future<void> delete(String endpoint) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _httpClient.delete(uri, headers: headers);

      if (response.statusCode >= 400) {
        handleHttpError(response);
      }
    } on SocketException {
      throw const NetworkException();
    }
  }

  /// Multipart POST request (for file uploads)
  static Future<Map<String, dynamic>> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
  }) async {
    try {
      final headers = await getAuthHeaders(contentType: 'multipart/form-data');
      final uri = Uri.parse('$_baseUrl$endpoint');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        handleHttpError(response);
      }

      return json.decode(response.body);
    } on SocketException {
      throw const NetworkException();
    }
  }

  /// Create multipart file from File
  static Future<http.MultipartFile> createMultipartFile(
    String field,
    File file, {
    String? mimeType,
  }) async {
    final filename = file.path.split('/').last;
    final extension = filename.split('.').last.toLowerCase();

    final contentType =
        mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('image', extension == 'jpg' ? 'jpeg' : extension);

    return http.MultipartFile.fromPath(
      field,
      file.path,
      filename: filename,
      contentType: contentType,
    );
  }

  /// Get base URL
  static String get baseUrl => _baseUrl;

  /// Dispose HTTP client
  static void dispose() {
    _httpClient.close();
  }
}
