import 'package:equatable/equatable.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/report/domain/entities/report.dart';
import 'package:letmegoo/features/report/domain/repositories/report_repository.dart';

/// Use case for creating a new report
///
/// This use case handles the creation of a new report with all necessary
/// information including vehicle details, location, images, and notes.
/// Supports both anonymous and identified reporting.
class CreateReport implements UseCase<Report, CreateReportParams> {
  final ReportRepository repository;

  const CreateReport(this.repository);

  @override
  Future<Report> call(CreateReportParams params) async {
    // Validate params before calling repository
    params.validate();

    return await repository.createReport(
      vehicleNumber: params.vehicleNumber,
      notes: params.notes,
      latitude: params.latitude,
      longitude: params.longitude,
      location: params.location,
      imagePaths: params.imagePaths,
      isAnonymous: params.isAnonymous,
    );
  }
}

/// Parameters required to create a new report
///
/// Contains all information needed to file a report including:
/// - Vehicle identification (number)
/// - Report details (notes)
/// - Location data (latitude, longitude, optional address)
/// - Optional supporting images
/// - Privacy setting (anonymous or not)
class CreateReportParams extends Equatable {
  /// The vehicle registration/license plate number being reported
  final String vehicleNumber;

  /// Detailed notes/description of the issue being reported
  final String notes;

  /// Latitude coordinate of the report location
  final String latitude;

  /// Longitude coordinate of the report location
  final String longitude;

  /// Optional human-readable location/address
  final String? location;

  /// Optional list of image file paths as supporting evidence
  final List<String>? imagePaths;

  /// Whether this report should be filed anonymously
  final bool isAnonymous;

  const CreateReportParams({
    required this.vehicleNumber,
    required this.notes,
    required this.latitude,
    required this.longitude,
    this.location,
    this.imagePaths,
    this.isAnonymous = false,
  });

  /// Validates the parameters
  ///
  /// Throws [ArgumentError] if any required field is invalid
  void validate() {
    if (vehicleNumber.trim().isEmpty) {
      throw ArgumentError('Vehicle number cannot be empty');
    }

    if (notes.trim().isEmpty) {
      throw ArgumentError('Notes cannot be empty');
    }

    // Validate latitude/longitude are valid numbers
    final lat = double.tryParse(latitude);
    if (lat == null || lat < -90 || lat > 90) {
      throw ArgumentError('Invalid latitude: must be between -90 and 90');
    }

    final lng = double.tryParse(longitude);
    if (lng == null || lng < -180 || lng > 180) {
      throw ArgumentError('Invalid longitude: must be between -180 and 180');
    }
  }

  /// Creates a copy of this params with optional overrides
  CreateReportParams copyWith({
    String? vehicleNumber,
    String? notes,
    String? latitude,
    String? longitude,
    String? location,
    List<String>? imagePaths,
    bool? isAnonymous,
  }) {
    return CreateReportParams(
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      imagePaths: imagePaths ?? this.imagePaths,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [
    vehicleNumber,
    notes,
    latitude,
    longitude,
    location,
    imagePaths,
    isAnonymous,
  ];

  @override
  String toString() {
    return 'CreateReportParams('
        'vehicleNumber: $vehicleNumber, '
        'notes: ${notes.substring(0, notes.length > 20 ? 20 : notes.length)}..., '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'location: $location, '
        'imagesCount: ${imagePaths?.length ?? 0}, '
        'isAnonymous: $isAnonymous'
        ')';
  }
}
