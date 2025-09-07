class VehicleType {
  final String value;
  final String displayName;

  VehicleType({required this.value, required this.displayName});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      value: json['value'] ?? '',
      displayName: json['display_name'] ?? '',
    );
  }

  @override
  String toString() => displayName;
}
