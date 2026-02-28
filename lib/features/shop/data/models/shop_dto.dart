import 'package:letmegoo/features/shop/domain/entities/shop.dart';

/// Data Transfer Object for Shop
class ShopDto {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String email;
  final String website;
  final String category;
  final String operatingHours;
  final bool isActive;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopDto({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.category,
    required this.operatingHours,
    required this.isActive,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopDto.fromJson(Map<String, dynamic> json) {
    return ShopDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
      category: json['category'] as String,
      operatingHours: json['operating_hours'] as String,
      isActive: json['is_active'] as bool,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
      'category': category,
      'operating_hours': operatingHours,
      'is_active': isActive,
      if (imageUrl != null) 'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert DTO to domain entity
  Shop toEntity() {
    return Shop(
      id: id,
      name: name,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phoneNumber: phoneNumber,
      email: email,
      website: website,
      category: category,
      operatingHours: operatingHours,
      isActive: isActive,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// DTO for paginated shop list response
class ShopListResponseDto {
  final int limit;
  final int offset;
  final String? next;
  final String? previous;
  final List<ShopDto> items;

  ShopListResponseDto({
    required this.limit,
    required this.offset,
    this.next,
    this.previous,
    required this.items,
  });

  factory ShopListResponseDto.fromJson(Map<String, dynamic> json) {
    return ShopListResponseDto(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      items:
          (json['items'] as List)
              .map((item) => ShopDto.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }
}
