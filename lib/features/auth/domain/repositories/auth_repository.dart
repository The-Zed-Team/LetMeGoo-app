import 'dart:io';
import 'package:letmegoo/features/auth/domain/entities/user.dart';

/// Abstract repository for authentication operations
///
/// This defines the contract that data layer must implement.
abstract class AuthRepository {
  /// Authenticate user with Firebase and backend
  Future<User> authenticateUser();

  /// Update user profile information
  Future<User> updateUserProfile({
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

  /// Logout user
  Future<void> logout();

  /// Get current cached user
  User? getCachedUser();

  /// Clear user cache
  void clearCache();
}
