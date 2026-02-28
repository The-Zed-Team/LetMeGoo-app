import 'dart:io';
import 'package:letmegoo/features/auth/data/models/user_dto.dart';

/// Abstract remote data source for authentication
///
/// Defines the contract for authentication API operations.
abstract class AuthRemoteDataSource {
  /// Authenticate user with Firebase token
  Future<UserDto> authenticateUser();

  /// Update user profile
  Future<UserDto> updateUserProfile({
    required String fullname,
    required String email,
    String? phoneNumber,
    String? companyName,
    File? profileImage,
  });

  /// Update user status
  Future<void> updateUserStatus(String newStatus);

  /// Update privacy preference
  Future<void> updatePrivacyPreference(String privacyPreference);

  /// Delete user account
  Future<void> deleteUserAccount();
}
