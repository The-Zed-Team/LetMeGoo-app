import 'package:equatable/equatable.dart';

/// Domain entity for Report
class Report extends Equatable {
  final String id;
  final int reportNumber;
  final ReportedVehicle vehicle;
  final String notes;
  final ReportStatus currentStatus;
  final bool isClosed;
  final bool isAnonymous;
  final Reporter reporter;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? latitude;
  final String? longitude;
  final String? location;
  final List<ReportImage> images;
  final List<StatusLog> statusLogs;

  const Report({
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

  @override
  List<Object?> get props => [id];
}

/// Reported vehicle information
class ReportedVehicle extends Equatable {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String? brand;
  final VehicleImageUrls? image;
  final VehicleOwner? owner;

  const ReportedVehicle({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    this.brand,
    this.image,
    this.owner,
  });

  @override
  List<Object?> get props => [id, vehicleNumber];
}

/// Vehicle owner information
class VehicleOwner extends Equatable {
  final String id;
  final String? privacyPreference;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? companyName;

  const VehicleOwner({
    required this.id,
    this.privacyPreference,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.companyName,
  });

  @override
  List<Object?> get props => [id];
}

/// Report reporter information
class Reporter extends Equatable {
  final String id;
  final String? privacyPreference;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? companyName;

  const Reporter({
    required this.id,
    this.privacyPreference,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.companyName,
  });

  String get displayName {
    if (fullname != null &&
        fullname!.isNotEmpty &&
        fullname != 'Anonymous User') {
      return fullname!;
    }
    return 'Anonymous User';
  }

  @override
  List<Object?> get props => [id];
}

/// Report image with different resolutions
class ReportImage extends Equatable {
  final String id;
  final String? thumbnail;
  final String? medium;
  final String? large;
  final String? original;

  const ReportImage({
    required this.id,
    this.thumbnail,
    this.medium,
    this.large,
    this.original,
  });

  /// Get the best available image quality
  String? get bestImage => large ?? medium ?? original ?? thumbnail;

  @override
  List<Object?> get props => [id];
}

/// Vehicle image URLs
class VehicleImageUrls extends Equatable {
  final String? thumbnail;
  final String? medium;
  final String? large;
  final String? original;

  const VehicleImageUrls({
    this.thumbnail,
    this.medium,
    this.large,
    this.original,
  });

  String? get bestImage => large ?? medium ?? original ?? thumbnail;

  @override
  List<Object?> get props => [thumbnail, medium, large, original];
}

/// Status change log entry
class StatusLog extends Equatable {
  final String id;
  final String status;
  final DateTime timestamp;

  const StatusLog({
    required this.id,
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, status, timestamp];
}

/// Report status enum
enum ReportStatus {
  waiting,
  seen,
  responded,
  blockCleared,
  solved,
  unknown;

  static ReportStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return ReportStatus.waiting;
      case 'seen':
        return ReportStatus.seen;
      case 'responded':
        return ReportStatus.responded;
      case 'block_cleared':
      case 'blockcleared':
        return ReportStatus.blockCleared;
      case 'solved':
        return ReportStatus.solved;
      default:
        return ReportStatus.unknown;
    }
  }

  String toDisplayString() {
    switch (this) {
      case ReportStatus.waiting:
        return 'Waiting';
      case ReportStatus.seen:
        return 'Seen';
      case ReportStatus.responded:
        return 'Responded';
      case ReportStatus.blockCleared:
        return 'Block Cleared';
      case ReportStatus.solved:
        return 'Solved';
      case ReportStatus.unknown:
        return 'Unknown';
    }
  }
}
