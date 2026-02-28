import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';

/// Data Transfer Object for Vehicle
class VehicleDto {
  final String id;
  final String name;
  final String vehicleNumber;
  final VehicleOwnerDto? owner;
  final String fuelType;
  final String vehicleType;
  final String? brand;
  final VehicleImageDto? image;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VehicleDto({
    required this.id,
    required this.name,
    required this.vehicleNumber,
    this.owner,
    required this.fuelType,
    required this.vehicleType,
    this.brand,
    this.image,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  /// Parse vehicle_type which can be either a String or a nested object {key, value}
  static String _parseVehicleType(dynamic vehicleType) {
    if (vehicleType == null) return '';
    if (vehicleType is String) return vehicleType;
    if (vehicleType is Map<String, dynamic>) {
      // Search API returns {key: "car", value: "Car"} object
      return vehicleType['value']?.toString() ??
          vehicleType['key']?.toString() ??
          '';
    }
    return vehicleType.toString();
  }

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      owner:
          json['owner'] != null && json['owner'] is Map<String, dynamic>
              ? VehicleOwnerDto.fromJson(json['owner'] as Map<String, dynamic>)
              : null,
      fuelType: json['fuel_type']?.toString() ?? '',
      vehicleType: _parseVehicleType(json['vehicle_type']),
      brand: json['brand']?.toString(),
      image:
          json['image'] != null && json['image'] is Map<String, dynamic>
              ? VehicleImageDto.fromJson(json['image'] as Map<String, dynamic>)
              : null,
      isVerified: json['is_verified'] == true || json['is_verified'] == 'true',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicle_number': vehicleNumber,
      'fuel_type': fuelType,
      'vehicle_type': vehicleType,
      'brand': brand,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Vehicle toEntity() {
    return Vehicle(
      id: id,
      name: name,
      vehicleNumber: vehicleNumber,
      owner: owner?.toEntity() ?? VehicleOwner.empty(),
      fuelType: fuelType,
      vehicleType: vehicleType,
      brand: brand,
      image: image?.toEntity(),
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// DTO for Vehicle Owner
class VehicleOwnerDto {
  final String id;
  final String? privacyPreference;
  final String? fullname;
  final String? email;
  final String? phoneNumber;

  const VehicleOwnerDto({
    required this.id,
    this.privacyPreference,
    this.fullname,
    this.email,
    this.phoneNumber,
  });

  factory VehicleOwnerDto.fromJson(Map<String, dynamic> json) {
    return VehicleOwnerDto(
      id: json['id']?.toString() ?? '',
      privacyPreference: json['privacy_preference']?.toString(),
      fullname: json['fullname']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
    );
  }

  VehicleOwner toEntity() {
    return VehicleOwner(
      id: id,
      privacyPreference: _parsePrivacyPreference(privacyPreference),
      fullname: fullname ?? '',
      email: email ?? '',
      phoneNumber: phoneNumber ?? '',
    );
  }

  PrivacyPreference _parsePrivacyPreference(String? value) {
    switch (value) {
      case 'public':
        return PrivacyPreference.public;
      case 'private':
        return PrivacyPreference.private;
      default:
        return PrivacyPreference.anonymous;
    }
  }
}

/// DTO for Vehicle Image
class VehicleImageDto {
  final String? thumbnail;
  final String? medium;
  final String? large;
  final String? original;

  const VehicleImageDto({
    this.thumbnail,
    this.medium,
    this.large,
    this.original,
  });

  factory VehicleImageDto.fromJson(Map<String, dynamic> json) {
    return VehicleImageDto(
      thumbnail: json['thumbnail']?.toString(),
      medium: json['medium']?.toString(),
      large: json['large']?.toString(),
      original: json['original']?.toString(),
    );
  }

  VehicleImage toEntity() {
    return VehicleImage(
      thumbnail: thumbnail,
      medium: medium,
      large: large,
      original: original,
    );
  }
}

/// DTO for Vehicle Type Info
class VehicleTypeInfoDto {
  final String key;
  final String value;

  const VehicleTypeInfoDto({required this.key, required this.value});

  factory VehicleTypeInfoDto.fromJson(Map<String, dynamic> json) {
    return VehicleTypeInfoDto(
      key: json['display_name']?.toString() ?? json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  VehicleTypeInfo toEntity() {
    return VehicleTypeInfo(key: key, value: value);
  }
}
