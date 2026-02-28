import 'package:letmegoo/features/report/domain/entities/report.dart' as domain;

/// DTO for Report API serialization
class ReportDto {
  final String id;
  final int reportNumber;
  final ReportedVehicleDto vehicle;
  final String notes;
  final String currentStatus;
  final bool isClosed;
  final bool isAnonymous;
  final ReporterDto reporter;
  final String createdAt;
  final String updatedAt;
  final String? latitude;
  final String? longitude;
  final String? location;
  final List<ReportImageDto> images;
  final List<StatusLogDto> statusLogs;

  ReportDto({
    required this.id,
    required this.reportNumber,
    required this.vehicle,
    required this.notes,
    required this.currentStatus,
    required this.isClosed,
    required this.isAnonymous,
    required this.reporter,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.location,
    required this.images,
    required this.statusLogs,
  });

  factory ReportDto.fromJson(Map<String, dynamic> json) {
    // Handle current_status which can be either String or Map
    String currentStatus;
    if (json['current_status'] is Map<String, dynamic>) {
      final statusMap = json['current_status'] as Map<String, dynamic>;
      currentStatus = statusMap['key']?.toString() ?? 'unknown';
    } else {
      currentStatus = json['current_status']?.toString() ?? 'unknown';
    }

    return ReportDto(
      id: json['id']?.toString() ?? '',
      reportNumber: json['report_number'] ?? 0,
      vehicle: ReportedVehicleDto.fromJson(json['vehicle'] ?? {}),
      notes: json['notes']?.toString() ?? '',
      currentStatus: currentStatus,
      isClosed: json['is_closed'] ?? false,
      isAnonymous: json['is_anonymous'] ?? false,
      reporter: ReporterDto.fromJson(json['reporter'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      location: json['location']?.toString(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => ReportImageDto.fromJson(img))
              .toList() ??
          [],
      statusLogs:
          (json['status_logs'] as List<dynamic>?)
              ?.map((log) => StatusLogDto.fromJson(log))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_number': reportNumber,
      'vehicle': vehicle.toJson(),
      'notes': notes,
      'current_status': currentStatus,
      'is_closed': isClosed,
      'is_anonymous': isAnonymous,
      'reporter': reporter.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'images': images.map((img) => img.toJson()).toList(),
      'status_logs': statusLogs.map((log) => log.toJson()).toList(),
    };
  }

  domain.Report toEntity() {
    return domain.Report(
      id: id,
      reportNumber: reportNumber,
      vehicle: vehicle.toEntity(),
      notes: notes,
      currentStatus: domain.ReportStatus.fromString(currentStatus),
      isClosed: isClosed,
      isAnonymous: isAnonymous,
      reporter: reporter.toEntity(),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      location: location,
      images: images.map((img) => img.toEntity()).toList(),
      statusLogs: statusLogs.map((log) => log.toEntity()).toList(),
    );
  }
}

class ReportedVehicleDto {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String? brand;
  final Map<String, dynamic>? image;
  final VehicleOwnerDto? owner;

  ReportedVehicleDto({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    this.brand,
    this.image,
    this.owner,
  });

  factory ReportedVehicleDto.fromJson(Map<String, dynamic> json) {
    return ReportedVehicleDto(
      id: json['id']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      brand: json['brand']?.toString(),
      image: json['image'] as Map<String, dynamic>?,
      owner:
          json['owner'] != null
              ? VehicleOwnerDto.fromJson(json['owner'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'brand': brand,
      'image': image,
      'owner': owner?.toJson(),
    };
  }

  domain.ReportedVehicle toEntity() {
    domain.VehicleImageUrls? imageUrls;
    if (image != null) {
      imageUrls = domain.VehicleImageUrls(
        thumbnail: image!['thumbnail']?.toString(),
        medium: image!['medium']?.toString(),
        large: image!['large']?.toString(),
        original: image!['original']?.toString(),
      );
    }

    return domain.ReportedVehicle(
      id: id,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      brand: brand,
      image: imageUrls,
      owner: owner?.toEntity(),
    );
  }
}

class VehicleOwnerDto {
  final String id;
  final String? privacyPreference;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? companyName;

  VehicleOwnerDto({
    required this.id,
    this.privacyPreference,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.companyName,
  });

  factory VehicleOwnerDto.fromJson(Map<String, dynamic> json) {
    return VehicleOwnerDto(
      id: json['id']?.toString() ?? '',
      privacyPreference: json['privacy_preference']?.toString(),
      fullname: json['fullname']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      companyName: json['company_name']?.toString(),
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

  domain.VehicleOwner toEntity() {
    return domain.VehicleOwner(
      id: id,
      privacyPreference: privacyPreference,
      fullname: fullname,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      companyName: companyName,
    );
  }
}

class ReporterDto {
  final String id;
  final String? privacyPreference;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? companyName;

  ReporterDto({
    required this.id,
    this.privacyPreference,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.companyName,
  });

  factory ReporterDto.fromJson(Map<String, dynamic> json) {
    return ReporterDto(
      id: json['id']?.toString() ?? '',
      privacyPreference: json['privacy_preference']?.toString(),
      fullname: json['fullname']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      companyName: json['company_name']?.toString(),
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

  domain.Reporter toEntity() {
    return domain.Reporter(
      id: id,
      privacyPreference: privacyPreference,
      fullname: fullname,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      companyName: companyName,
    );
  }
}

class ReportImageDto {
  final String id;
  final Map<String, dynamic> image;

  ReportImageDto({required this.id, required this.image});

  factory ReportImageDto.fromJson(Map<String, dynamic> json) {
    return ReportImageDto(
      id: json['id']?.toString() ?? '',
      image: json['image'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image': image};
  }

  domain.ReportImage toEntity() {
    return domain.ReportImage(
      id: id,
      thumbnail: image['thumbnail']?.toString(),
      medium: image['medium']?.toString(),
      large: image['large']?.toString(),
      original: image['original']?.toString(),
    );
  }
}

class StatusLogDto {
  final String id;
  final String status;
  final String timestamp;

  StatusLogDto({
    required this.id,
    required this.status,
    required this.timestamp,
  });

  factory StatusLogDto.fromJson(Map<String, dynamic> json) {
    return StatusLogDto(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'status': status, 'timestamp': timestamp};
  }

  domain.StatusLog toEntity() {
    return domain.StatusLog(
      id: id,
      status: status,
      timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
    );
  }
}
