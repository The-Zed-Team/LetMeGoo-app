import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  locationError,
  systemError, // Added for system-level crashes
}

class LocationResult {
  final Position? position;
  final LocationErrorType? errorType;
  final String? errorMessage;

  LocationResult({this.position, this.errorType, this.errorMessage});

  bool get isSuccess => position != null;
  bool get hasError => errorType != null;
}

class LocationService {
  static LocationService? _instance;
  LocationService._internal();

  factory LocationService() {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  /// Get current location with crash-resistant settings
  Future<LocationResult> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.medium, // Changed from high
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } on PlatformException catch (e) {
        return LocationResult(
          errorType: LocationErrorType.systemError,
          errorMessage: "System location service error: ${e.message}",
        );
      }

      if (!serviceEnabled) {
        return LocationResult(
          errorType: LocationErrorType.serviceDisabled,
          errorMessage: "Location services are disabled",
        );
      }

      // Check location permission
      LocationPermission permission;
      try {
        permission = await Geolocator.checkPermission();
      } on PlatformException catch (e) {
        return LocationResult(
          errorType: LocationErrorType.systemError,
          errorMessage: "Permission check failed: ${e.message}",
        );
      }

      if (permission == LocationPermission.denied) {
        try {
          permission = await Geolocator.requestPermission();
        } on PlatformException catch (e) {
          return LocationResult(
            errorType: LocationErrorType.systemError,
            errorMessage: "Permission request failed: ${e.message}",
          );
        }

        if (permission == LocationPermission.denied) {
          return LocationResult(
            errorType: LocationErrorType.permissionDenied,
            errorMessage: "Location permission denied",
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          errorType: LocationErrorType.permissionPermanentlyDenied,
          errorMessage: "Location permission permanently denied",
        );
      }

      // Get current position with crash-resistant settings
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeLimit,
          forceAndroidLocationManager:
              true, // Use Android LocationManager instead of Fused Location
        );
      } on TimeoutException {
        // Try to get last known position as fallback
        try {
          Position? lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            return LocationResult(position: lastPosition);
          }
        } catch (e) {
          // Ignore and fall through to timeout error
        }

        return LocationResult(
          errorType: LocationErrorType.locationError,
          errorMessage:
              "Location request timed out and no cached location available",
        );
      } on PlatformException catch (e) {
        // Handle specific platform exceptions
        if (e.message?.contains('DeadSystem') == true ||
            e.message?.contains('Binder transaction failure') == true) {
          return LocationResult(
            errorType: LocationErrorType.systemError,
            errorMessage:
                "System location service crashed. Please restart your device.",
          );
        }

        return LocationResult(
          errorType: LocationErrorType.locationError,
          errorMessage: "Platform error: ${e.message}",
        );
      }

      return LocationResult(position: position);
    } catch (e) {
      // Handle any other unexpected errors
      String errorMessage = e.toString();

      if (errorMessage.contains('DeadSystem') ||
          errorMessage.contains('Binder transaction failure')) {
        return LocationResult(
          errorType: LocationErrorType.systemError,
          errorMessage:
              "System location service crashed. Please restart your device.",
        );
      }

      return LocationResult(
        errorType: LocationErrorType.locationError,
        errorMessage: "Error getting location: $e",
      );
    }
  }

  /// Get address from coordinates - simplified version
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // For now, return coordinates as string
    // You can add geocoding package later for proper address resolution
    return "Location: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}";
  }

  /// Show location service dialog
  static void showLocationServiceDialog(
    BuildContext context, {
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Location Services Disabled"),
            content: const Text(
              "Location services are disabled. Please enable location services to continue.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.openLocationSettings();
                },
                child: const Text("Settings"),
              ),
            ],
          ),
    );
  }

  /// Show permission denied dialog
  static void showPermissionDeniedDialog(
    BuildContext context, {
    VoidCallback? onCancel,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Location Permission Required"),
            content: const Text(
              "Location permission is required to submit a report. Please grant location permission to continue.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry?.call();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
    );
  }

  /// Show permission permanently denied dialog
  static void showPermissionPermanentlyDeniedDialog(
    BuildContext context, {
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Location Permission Required"),
            content: const Text(
              "Location permission has been permanently denied. Please enable it in app settings to continue.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text("Settings"),
              ),
            ],
          ),
    );
  }

  /// Show system error dialog
  static void showSystemErrorDialog(
    BuildContext context, {
    String? message,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("System Error"),
            content: Text(
              message ??
                  "The device location system has encountered an error. Please restart your device and try again.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  /// Show location error dialog
  static void showLocationErrorDialog(
    BuildContext context, {
    String? message,
    VoidCallback? onCancel,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Location Error"),
            content: Text(
              message ??
                  "Unable to get your current location. Please try again or check your location settings.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: const Text("Cancel"),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  child: const Text("Retry"),
                ),
            ],
          ),
    );
  }
}
