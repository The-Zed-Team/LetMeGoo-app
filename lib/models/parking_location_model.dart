// lib/models/parking_location.dart
class ParkingLocation {
  final String id;
  final String? vehicleId;
  final String vehicleNumber;
  final UserInfo user;
  final Vehicle? vehicle;
  final double latitude;
  final double longitude;
  final String? notes;
  final ImageUrls? image;
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingLocation({
    required this.id,
    this.vehicleId,
    required this.vehicleNumber,
    required this.user,
    this.vehicle,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.image,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParkingLocation.fromJson(Map<String, dynamic> json) {
    return ParkingLocation(
      id: json['id'] ?? '',
      vehicleId: json['vehicle_id'],
      vehicleNumber: json['vehicle_number'] ?? '',
      user: UserInfo.fromJson(json['user'] ?? {}),
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      notes: json['notes'],
      image: json['image'] != null ? ImageUrls.fromJson(json['image']) : null,
      visibility: json['visibility'] ?? 'public',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'vehicle_number': vehicleNumber,
      'user': user.toJson(),
      'vehicle': vehicle?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'image': image?.toJson(),
      'visibility': visibility,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get displayNotes => notes ?? 'No notes provided';
  bool get hasImage => image != null;
  String? get imageUrl =>
      image?.medium ?? image?.original; // Prefer medium, fallback to original
  bool get isPublic => visibility == 'public';

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class ImageUrls {
  final String? thumbnail;
  final String? medium;
  final String? large;
  final String? original;

  ImageUrls({this.thumbnail, this.medium, this.large, this.original});

  factory ImageUrls.fromJson(Map<String, dynamic> json) {
    return ImageUrls(
      thumbnail: json['thumbnail'],
      medium: json['medium'],
      large: json['large'],
      original: json['original'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'medium': medium,
      'large': large,
      'original': original,
    };
  }

  // Helper to get the best available image URL
  String? get bestUrl => medium ?? large ?? original ?? thumbnail;
}

class UserInfo {
  final String id;
  final String privacyPreference;
  final String fullname;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? companyName;

  UserInfo({
    required this.id,
    required this.privacyPreference,
    required this.fullname,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.companyName,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      privacyPreference: json['privacy_preference'] ?? 'public',
      fullname: json['fullname'] ?? 'Unknown User',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      companyName: json['company_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'privacy_preference': privacyPreference,
      'fullname': fullname,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'company_name': companyName,
    };
  }
}

class Vehicle {
  final String id;
  final String vehicleNumber;
  final String? vehicleType;
  final String? model;
  final String? year;
  final String? color;

  Vehicle({
    required this.id,
    required this.vehicleNumber,
    this.vehicleType,
    this.model,
    this.year,
    this.color,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      vehicleType: json['vehicle_type'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'model': model,
      'year': year,
      'color': color,
    };
  }
}

class ParkingLocationRequest {
  final String vehicleNumber;
  final double latitude;
  final double longitude;
  final String? notes;
  final String? imagePath; // Local file path
  final String visibility;

  ParkingLocationRequest({
    required this.vehicleNumber,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.imagePath,
    this.visibility = 'public',
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicle_number': vehicleNumber,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'visibility': visibility,
    };
  }
}

class ParkingLocationListResponse {
  final int limit;
  final int offset;
  final String? next;
  final String? previous;
  final List<ParkingLocation> items;

  ParkingLocationListResponse({
    required this.limit,
    required this.offset,
    this.next,
    this.previous,
    required this.items,
  });

  factory ParkingLocationListResponse.fromJson(Map<String, dynamic> json) {
    return ParkingLocationListResponse(
      limit: json['limit'] ?? 10,
      offset: json['offset'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ParkingLocation.fromJson(item))
              .toList() ??
          [],
    );
  }

  bool get hasMore => next != null;
  bool get isEmpty => items.isEmpty;
  int get totalCount => items.length;
}
