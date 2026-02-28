import 'package:equatable/equatable.dart';

/// Privacy preference enum
enum PrivacyPreference { public, private, anonymous }

/// Vehicle owner value object
class VehicleOwner extends Equatable {
  final String id;
  final PrivacyPreference privacyPreference;
  final String fullname;
  final String email;
  final String phoneNumber;

  const VehicleOwner({
    required this.id,
    required this.privacyPreference,
    required this.fullname,
    required this.email,
    required this.phoneNumber,
  });

  /// Empty constructor for when owner data is not available
  factory VehicleOwner.empty() {
    return const VehicleOwner(
      id: '',
      privacyPreference: PrivacyPreference.anonymous,
      fullname: '',
      email: '',
      phoneNumber: '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    privacyPreference,
    fullname,
    email,
    phoneNumber,
  ];
}

/// Vehicle image value object
class VehicleImage extends Equatable {
  final String? thumbnail;
  final String? medium;
  final String? large;
  final String? original;

  const VehicleImage({this.thumbnail, this.medium, this.large, this.original});

  /// Get the best available image URL
  String? get bestImage => large ?? medium ?? original ?? thumbnail;

  @override
  List<Object?> get props => [thumbnail, medium, large, original];
}

/// Vehicle entity
class Vehicle extends Equatable {
  final String id;
  final String name;
  final String vehicleNumber;
  final VehicleOwner owner;
  final String fuelType;
  final String vehicleType;
  final String? brand;
  final VehicleImage? image;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Vehicle({
    required this.id,
    required this.name,
    required this.vehicleNumber,
    required this.owner,
    required this.fuelType,
    required this.vehicleType,
    this.brand,
    this.image,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  /// Display name (name or vehicle number)
  String get displayName => name.isNotEmpty ? name : vehicleNumber;

  /// Owner name
  String get ownerName => owner.fullname;

  /// Image URL
  String? get imageUrl => image?.bestImage;

  /// Create copy with updated fields
  Vehicle copyWith({
    String? id,
    String? name,
    String? vehicleNumber,
    VehicleOwner? owner,
    String? fuelType,
    String? vehicleType,
    String? brand,
    VehicleImage? image,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      owner: owner ?? this.owner,
      fuelType: fuelType ?? this.fuelType,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      image: image ?? this.image,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    vehicleNumber,
    owner,
    fuelType,
    vehicleType,
    brand,
    image,
    isVerified,
    createdAt,
    updatedAt,
  ];
}

/// Vehicle type info
class VehicleTypeInfo extends Equatable {
  final String key;
  final String value;

  const VehicleTypeInfo({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}
