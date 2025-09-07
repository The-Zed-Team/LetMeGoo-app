// lib/models/report_request.dart
import 'dart:io';

class ReportRequest {
  final String vehicleId;
  final List<File> images;
  final bool isAnonymous;
  final String notes;
  final String? longitude;
  final String? latitude;
  final String? location;

  ReportRequest({
    required this.vehicleId,
    required this.images,
    required this.isAnonymous,
    required this.notes,
    this.longitude,
    this.latitude,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'is_anonymous': isAnonymous,
      'notes': notes,
      'longitude': longitude,
      'latitude': latitude,
      'location': location,
      // Images will be handled separately in multipart form data
    };
  }

  // Convert to form data for multipart request
  Map<String, String> toFormData() {
    return {
      'vehicle_id': vehicleId,
      'is_anonymous': isAnonymous.toString(),
      'notes': notes,
      if (longitude != null) 'longitude': longitude!,
      if (latitude != null) 'latitude': latitude!,
      if (location != null) 'location': location!,
    };
  }
}
