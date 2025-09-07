// Example of how to use the LocationService in your Flutter app
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class LocationServiceExample extends StatefulWidget {
  const LocationServiceExample({super.key});

  @override
  State<LocationServiceExample> createState() => _LocationServiceExampleState();
}

class _LocationServiceExampleState extends State<LocationServiceExample> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  String? _locationInfo;
  String? _address;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationInfo = null;
      _address = null;
    });

    try {
      final result = await _locationService.getCurrentLocation();

      if (result.isSuccess && result.position != null) {
        final position = result.position!;
        
        // Update location info
        setState(() {
          _locationInfo = 'Lat: ${position.latitude.toStringAsFixed(6)}, '
                        'Lng: ${position.longitude.toStringAsFixed(6)}';
        });

        // Get address
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        setState(() {
          _address = address;
        });
      } else {
        // Handle error
        _handleLocationError(result);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLocationError(LocationResult result) {
    switch (result.errorType) {
      case LocationErrorType.serviceDisabled:
        LocationService.showLocationServiceDialog(context);
        break;
      case LocationErrorType.permissionDenied:
        LocationService.showPermissionDeniedDialog(
          context,
          onRetry: _getCurrentLocation,
        );
        break;
      case LocationErrorType.permissionPermanentlyDenied:
        LocationService.showPermissionPermanentlyDeniedDialog(context);
        break;
      case LocationErrorType.locationError:
        LocationService.showLocationErrorDialog(
          context,
          message: result.errorMessage,
          onRetry: _getCurrentLocation,
        );
        break;
      default:
        LocationService.showLocationErrorDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Service Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _getCurrentLocation,
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Getting Location...'),
                      ],
                    )
                  : const Text('Get Current Location'),
            ),
            const SizedBox(height: 20),
            if (_locationInfo != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Coordinates:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_locationInfo!),
                    ],
                  ),
                ),
              ),
            ],
            if (_address != null) ...[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_address!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Example of using LocationService in a simple function
class LocationServiceUsageExamples {
  static final LocationService _locationService = LocationService();

  /// Example 1: Simple location retrieval
  static Future<Position?> getLocationSimple() async {
    final result = await _locationService.getCurrentLocation();
    return result.position;
  }

  /// Example 2: Location retrieval with custom accuracy and timeout
  static Future<Position?> getLocationWithCustomSettings() async {
    final result = await _locationService.getCurrentLocation(
      accuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
    return result.position;
  }

  /// Example 3: Get location with address
  static Future<Map<String, dynamic>?> getLocationWithAddress() async {
    final result = await _locationService.getCurrentLocation();
    
    if (result.isSuccess && result.position != null) {
      final position = result.position!;
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
    
    return null;
  }

  /// Example 4: Handle location errors programmatically
  static Future<String> getLocationWithErrorHandling() async {
    final result = await _locationService.getCurrentLocation();
    
    if (result.isSuccess) {
      return 'Location obtained successfully';
    } else {
      switch (result.errorType) {
        case LocationErrorType.serviceDisabled:
          return 'Location services are disabled';
        case LocationErrorType.permissionDenied:
          return 'Location permission denied';
        case LocationErrorType.permissionPermanentlyDenied:
          return 'Location permission permanently denied';
        case LocationErrorType.locationError:
          return 'Error getting location: ${result.errorMessage}';
        default:
          return 'Unknown location error';
      }
    }
  }
}
