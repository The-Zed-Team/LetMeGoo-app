enum PrivacyPreference { public, private, anonymous }

class VehicleOwner {
  final String id;
  final PrivacyPreference privacyPreference;
  final String fullname;
  final String email;
  final String phoneNumber;

  VehicleOwner({
    required this.id,
    required this.privacyPreference,
    required this.fullname,
    required this.email,
    required this.phoneNumber,
  });

  factory VehicleOwner.fromJson(Map<String, dynamic> json) {
    return VehicleOwner(
      id: json['id']?.toString() ?? '',
      privacyPreference: PrivacyPreference.values.firstWhere(
        (e) => e.toString().split('.').last == json['privacy_preference'],
        orElse: () => PrivacyPreference.anonymous,
      ),
      fullname: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
    );
  }

  // Empty constructor for when owner data is not available
  factory VehicleOwner.empty() {
    return VehicleOwner(
      id: '',
      privacyPreference: PrivacyPreference.anonymous,
      fullname: '',
      email: '',
      phoneNumber: '',
    );
  }
}

class VehicleImage {
  final String? thumbnail;
  final String? medium;
  final String? large;
  final String? original;

  VehicleImage({this.thumbnail, this.medium, this.large, this.original});

  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      thumbnail: json['thumbnail'],
      medium: json['medium'],
      large: json['large'],
      original: json['original'],
    );
  }

  // Helper method to get the best available image URL
  String? get bestImage => large ?? medium ?? original ?? thumbnail;
}

class Vehicle {
  final String id;
  final String name;
  final String vehicleNumber;
  final VehicleOwner owner;
  final String fuelType;
  final String vehicleType;
  final String? brand;
  final VehicleImage? image;
  final bool isVerified;
  final DateTime createdAt; // Added for sorting
  final DateTime? updatedAt; // Added for tracking updates

  Vehicle({
    required this.id,
    required this.name,
    required this.vehicleNumber,
    required this.owner,
    required this.fuelType,
    required this.vehicleType,
    this.brand,
    this.image,
    required this.isVerified,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    try {
      return Vehicle(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        vehicleNumber: json['vehicle_number']?.toString() ?? '',
        owner:
            json['owner'] != null && json['owner'] is Map<String, dynamic>
                ? VehicleOwner.fromJson(json['owner'] as Map<String, dynamic>)
                : VehicleOwner.empty(), // Create an empty owner if not available
        fuelType: json['fuel_type']?.toString() ?? '',
        vehicleType: json['vehicle_type']?.toString() ?? '',
        brand: json['brand']?.toString(),
        image:
            json['image'] != null && json['image'] is Map<String, dynamic>
                ? VehicleImage.fromJson(json['image'] as Map<String, dynamic>)
                : null,
        isVerified:
            json['is_verified'] == true || json['is_verified'] == 'true',
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt:
            json['updated_at'] != null
                ? DateTime.tryParse(json['updated_at'])
                : null,
      );
    } catch (e) {
      print('Error parsing Vehicle from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  // Helper getters
  String get displayName => name.isNotEmpty ? name : vehicleNumber;
  String get ownerName => owner.fullname;
  String? get imageUrl => image?.bestImage;

  // Convert to JSON
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

  // Copy with method for updates
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
  String toString() {
    return 'Vehicle(id: $id, name: $name, vehicleNumber: $vehicleNumber, vehicleType: $vehicleType, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
