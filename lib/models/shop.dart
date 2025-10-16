class Shop {
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
  final String imageUrl;
  double? distance;

  Shop({
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
    required this.imageUrl,
    this.distance,
  });
}
