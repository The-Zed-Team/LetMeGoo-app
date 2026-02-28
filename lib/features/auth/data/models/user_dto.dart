import 'package:letmegoo/features/auth/domain/entities/user.dart';

/// Data Transfer Object for User
///
/// Handles JSON serialization/deserialization for API communication.
class UserDto {
  final String id;
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? fullname;
  final bool emailVerified;
  final String? profilePicture;
  final String? companyName;
  final String privacyPreference;

  const UserDto({
    required this.id,
    required this.uid,
    this.email,
    this.phoneNumber,
    this.fullname,
    required this.emailVerified,
    this.profilePicture,
    this.companyName,
    required this.privacyPreference,
  });

  /// Create UserDto from JSON
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      fullname: json['fullname']?.toString(),
      emailVerified: json['email_verified'] == true,
      profilePicture: json['profile_picture']?.toString(),
      companyName: json['company_name']?.toString(),
      privacyPreference: json['privacy_preference']?.toString() ?? 'private',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'phone_number': phoneNumber,
      'fullname': fullname,
      'email_verified': emailVerified,
      'profile_picture': profilePicture,
      'company_name': companyName,
      'privacy_preference': privacyPreference,
    };
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      uid: uid,
      email: email,
      phoneNumber: phoneNumber,
      fullname: fullname,
      emailVerified: emailVerified,
      profilePicture: profilePicture,
      companyName: companyName,
      privacyPreference: privacyPreference,
    );
  }

  /// Create from domain entity
  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      fullname: user.fullname,
      emailVerified: user.emailVerified,
      profilePicture: user.profilePicture,
      companyName: user.companyName,
      privacyPreference: user.privacyPreference,
    );
  }
}
