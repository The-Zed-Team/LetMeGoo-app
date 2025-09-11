// lib/services/flag_report_service.dart - Complete service for flagging reports

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart';

class FlagReportService {
  static const String baseUrl = 'https://api.letmegoo.com/api';
  static const Duration timeoutDuration = Duration(seconds: 15);

  /// Flag a report with optional image
  static Future<Map<String, dynamic>> flagReport({
    required String reportId,
    required String subject,
    required String description,
    File? image,
  }) async {
    try {
      // Get Firebase authentication token
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      final String? idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get authentication token');
      }

      // Create multipart request
      final uri = Uri.parse('$baseUrl/vehicle/report/flag/create/$reportId');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['subject'] = subject;
      request.fields['description'] = description;

      // Add image if provided
      if (image != null && await image.exists()) {
        final imageBytes = await image.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'flag_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      print('Flagging report: $reportId');
      print('Subject: $subject');
      print('Description: $description');
      print('Has image: ${image != null}');

      // Send request
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      print('Flag response status: ${response.statusCode}');
      print('Flag response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Report flagged successfully',
          'data': responseData,
        };
      } else {
        // Try to parse error message from response
        String errorMessage = 'Failed to flag report';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // If parsing fails, use default message
          errorMessage =
              'Failed to flag report. Status: ${response.statusCode}';
        }

        return {'success': false, 'message': errorMessage};
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timeout. Please check your internet connection.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error flagging report: $e');
      }
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  /// Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
