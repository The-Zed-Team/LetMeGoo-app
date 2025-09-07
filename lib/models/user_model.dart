// lib/models/user_model.dart
class UserModel {
  final String id;
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? fullname;
  final bool emailVerified;
  final String? profilePicture;
  final String? companyName;
  final String privacyPreference;

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'],
      fullname: json['fullname'],
      emailVerified: json['email_verified'] ?? false,
      profilePicture: json['profile_picture'],
      companyName: json['company_name'],
      privacyPreference: json['privacy_preference'] ?? 'private',
    );
  }

  bool get hasValidUsername => fullname != null && fullname!.isNotEmpty;

  // Helper method to get user initials
  String get initials {
    if (fullname!.isEmpty) return 'U';
    final names = fullname!.trim().split(' ');
    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : 'U';
    } else {
      return (names[0].isNotEmpty ? names[0][0] : '') +
          (names[1].isNotEmpty ? names[1][0] : '').toUpperCase();
    }
  }
}
