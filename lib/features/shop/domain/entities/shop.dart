class Shop {
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
  final double? distance; // Calculated client-side

  const Shop({
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
    this.distance,
  });

  /// Create a copy of this shop with updated fields
  Shop copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? email,
    String? website,
    String? category,
    String? operatingHours,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      category: category ?? this.category,
      operatingHours: operatingHours ?? this.operatingHours,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
    );
  }
}
