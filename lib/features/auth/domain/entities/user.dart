import 'package:equatable/equatable.dart';

/// User entity representing authenticated user in the domain layer
class User extends Equatable {
  final String id;
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? fullname;
  final bool emailVerified;
  final String? profilePicture;
  final String? companyName;
  final String privacyPreference;

  const User({
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

  /// Check if user has a valid username
  bool get hasValidUsername => fullname != null && fullname!.isNotEmpty;

  /// Get user initials for avatar
  String get initials {
    if (fullname == null || fullname!.isEmpty) return 'U';
    final names = fullname!.trim().split(' ');
    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : 'U';
    }
    return ((names[0].isNotEmpty ? names[0][0] : '') +
            (names[1].isNotEmpty ? names[1][0] : ''))
        .toUpperCase();
  }

  /// Get display name
  String get displayName => fullname ?? 'Unknown User';

  /// Create copy with updated fields
  User copyWith({
    String? id,
    String? uid,
    String? email,
    String? phoneNumber,
    String? fullname,
    bool? emailVerified,
    String? profilePicture,
    String? companyName,
    String? privacyPreference,
  }) {
    return User(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullname: fullname ?? this.fullname,
      emailVerified: emailVerified ?? this.emailVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      companyName: companyName ?? this.companyName,
      privacyPreference: privacyPreference ?? this.privacyPreference,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uid,
    email,
    phoneNumber,
    fullname,
    emailVerified,
    profilePicture,
    companyName,
    privacyPreference,
  ];
}
