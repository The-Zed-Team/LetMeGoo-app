// lib/models/vehicle_search_result.dart
class VehicleSearchResult {
  final String id;
  final String? name;
  final String vehicleNumber;
  final String? fuelType;
  final VehicleTypeInfo? vehicleType;
  final bool isVerified;

  VehicleSearchResult({
    required this.id,
    this.name,
    required this.vehicleNumber,
    this.fuelType,
    this.vehicleType,
    required this.isVerified,
  });

  factory VehicleSearchResult.fromJson(Map<String, dynamic> json) {
    return VehicleSearchResult(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      fuelType: json['fuel_type']?.toString(),
      vehicleType: json['vehicle_type'] != null 
          ? VehicleTypeInfo.fromJson(json['vehicle_type'] as Map<String, dynamic>)
          : null,
      isVerified: json['is_verified'] == true || json['is_verified'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicle_number': vehicleNumber,
      'fuel_type': fuelType,
      'vehicle_type': vehicleType?.toJson(),
      'is_verified': isVerified,
    };
  }
}

class VehicleTypeInfo {
  final String key;
  final String value;

  VehicleTypeInfo({
    required this.key,
    required this.value,
  });

  factory VehicleTypeInfo.fromJson(Map<String, dynamic> json) {
    return VehicleTypeInfo(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}
