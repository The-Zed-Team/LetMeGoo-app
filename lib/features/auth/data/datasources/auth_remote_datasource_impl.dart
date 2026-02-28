import 'dart:io';
import 'package:letmegoo/core/network/api_client.dart';
import 'package:letmegoo/core/error/exceptions.dart';
import 'package:letmegoo/features/auth/data/models/user_dto.dart';
import 'auth_remote_datasource.dart';

/// Implementation of AuthRemoteDataSource using API client
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserDto> authenticateUser() async {
    try {
      final response = await ApiClient.post('/auth/');
      return UserDto.fromJson(response);
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to authenticate: $e');
    }
  }

  @override
  Future<UserDto> updateUserProfile({
    required String fullname,
    required String email,
    String? phoneNumber,
    String? companyName,
    File? profileImage,
  }) async {
    try {
      if (profileImage != null) {
        // Use multipart for image upload
        final fields = {
          'fullname': fullname,
          'email': email,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (companyName != null) 'company_name': companyName,
        };

        final file = await ApiClient.createMultipartFile(
          'profile_picture',
          profileImage,
        );

        final response = await ApiClient.multipartPost(
          '/auth/update-profile/',
          fields: fields,
          files: [file],
        );
        return UserDto.fromJson(response);
      } else {
        // Regular JSON request
        final body = {
          'fullname': fullname,
          'email': email,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (companyName != null) 'company_name': companyName,
        };

        final response = await ApiClient.put(
          '/auth/update-profile/',
          body: body,
        );
        return UserDto.fromJson(response);
      }
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update profile: $e');
    }
  }

  @override
  Future<void> updateUserStatus(String newStatus) async {
    try {
      await ApiClient.put('/auth/update-status/', body: {'status': newStatus});
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update status: $e');
    }
  }

  @override
  Future<void> updatePrivacyPreference(String privacyPreference) async {
    try {
      await ApiClient.put(
        '/auth/privacy/',
        body: {'privacy_preference': privacyPreference},
      );
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update privacy preference: $e');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    try {
      await ApiClient.delete('/auth/delete-account/');
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to delete account: $e');
    }
  }
}
