// lib/providers/parking_location_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/models/parking_location_model.dart';
import 'package:letmegoo/services/parking_location_service.dart';

// Parking location state
class ParkingLocationState {
  final List<ParkingLocation> locations;
  final bool isLoading;
  final String? error;
  final DateTime? lastFetch;
  final bool hasReachedEnd;
  final int currentOffset;

  const ParkingLocationState({
    this.locations = const [],
    this.isLoading = false,
    this.error,
    this.lastFetch,
    this.hasReachedEnd = false,
    this.currentOffset = 0,
  });

  ParkingLocationState copyWith({
    List<ParkingLocation>? locations,
    bool? isLoading,
    String? error,
    DateTime? lastFetch,
    bool? hasReachedEnd,
    int? currentOffset,
  }) {
    return ParkingLocationState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastFetch: lastFetch ?? this.lastFetch,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }

  bool get hasNoLocations => locations.isEmpty;
  int get totalLocations => locations.length;

  // Check if data is stale (older than 5 minutes)
  bool get isDataStale {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch!).inMinutes > 5;
  }
}

// Parking location cache provider
class ParkingLocationCacheNotifier extends StateNotifier<DateTime?> {
  ParkingLocationCacheNotifier() : super(null);

  bool get isCacheValid {
    if (state == null) return false;
    return DateTime.now().difference(state!).inMinutes < 5;
  }

  void updateCacheTime() {
    state = DateTime.now();
  }

  void invalidateCache() {
    state = null;
  }
}

final parkingLocationCacheProvider =
    StateNotifierProvider<ParkingLocationCacheNotifier, DateTime?>((ref) {
      return ParkingLocationCacheNotifier();
    });

// Main parking location provider
class ParkingLocationNotifier extends StateNotifier<ParkingLocationState> {
  ParkingLocationNotifier() : super(const ParkingLocationState());

  Future<void> loadLocations({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    // Don't load if we have fresh data and not forcing refresh
    if (!forceRefresh && state.locations.isNotEmpty && !state.isDataStale) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔍 Loading parking locations...');
      final response = await ParkingLocationService.getParkingLocations(
        limit: 20,
        offset: 0,
      );

      if (mounted) {
        state = state.copyWith(
          locations: response.items,
          isLoading: false,
          error: null,
          lastFetch: DateTime.now(),
          hasReachedEnd: !response.hasMore,
          currentOffset: response.items.length,
        );
        print('✅ Loaded ${response.items.length} parking locations');
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString().replaceAll('Exception: ', ''),
        );
        print('❌ Error loading parking locations: $e');
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadLocations(forceRefresh: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasReachedEnd) return;

    state = state.copyWith(isLoading: true);

    try {
      print(
        '📄 Loading more parking locations (offset: ${state.currentOffset})...',
      );
      final response = await ParkingLocationService.getParkingLocations(
        limit: 20,
        offset: state.currentOffset,
      );

      if (mounted) {
        final updatedLocations = [...state.locations, ...response.items];
        state = state.copyWith(
          locations: updatedLocations,
          isLoading: false,
          error: null,
          hasReachedEnd: !response.hasMore,
          currentOffset: updatedLocations.length,
        );
        print('✅ Loaded ${response.items.length} more parking locations');
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString().replaceAll('Exception: ', ''),
        );
        print('❌ Error loading more parking locations: $e');
      }
    }
  }

  Future<bool> createLocation(ParkingLocationRequest request) async {
    try {
      print('🚗 Creating new parking location...');
      final newLocation = await ParkingLocationService.createParkingLocation(
        request,
      );

      if (mounted) {
        // Add the new location to the beginning of the list
        final updatedLocations = [newLocation, ...state.locations];
        state = state.copyWith(locations: updatedLocations, error: null);
        print('✅ Parking location created successfully');
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          error: e.toString().replaceAll('Exception: ', ''),
        );
      }
      print('❌ Error creating parking location: $e');
      return false;
    }
  }

  Future<bool> deleteLocation(String locationId) async {
    try {
      print('🗑️ Deleting parking location: $locationId');
      final success = await ParkingLocationService.deleteParkingLocation(
        locationId,
      );

      if (success && mounted) {
        // Remove the location from the list
        final updatedLocations =
            state.locations
                .where((location) => location.id != locationId)
                .toList();
        state = state.copyWith(locations: updatedLocations, error: null);
        print('✅ Parking location deleted successfully');
      }
      return success;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          error: e.toString().replaceAll('Exception: ', ''),
        );
      }
      print('❌ Error deleting parking location: $e');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void clearLocations() {
    state = const ParkingLocationState();
  }
}

// Provider instance
final parkingLocationProvider =
    StateNotifierProvider<ParkingLocationNotifier, ParkingLocationState>((ref) {
      return ParkingLocationNotifier();
    });

// Formatted providers for UI
final parkingLocationFormattedProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  final locationState = ref.watch(parkingLocationProvider);

  return locationState.locations.map((location) {
    return {
      'id': location.id,
      'vehicleNumber': location.vehicleNumber,
      'notes': location.displayNotes,
      'timeDate': location.formattedDate,
      'location':
          'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
      'visibility': location.visibility,
      'hasImage': location.hasImage,
      'image':
          location
              .imageUrl, // Use the imageUrl getter which handles the image object
      'latitude': location.latitude,
      'longitude': location.longitude,
      'user': location.user.fullname,
      'userImage': location.user.profilePicture,
      'createdAt': location.createdAt,
    };
  }).toList();
});

// Statistics provider
final parkingLocationStatsProvider = Provider<Map<String, int>>((ref) {
  final locationState = ref.watch(parkingLocationProvider);

  final publicCount = locationState.locations.where((l) => l.isPublic).length;
  final privateCount = locationState.locations.length - publicCount;
  final withImageCount =
      locationState.locations.where((l) => l.hasImage).length;

  return {
    'total': locationState.locations.length,
    'public': publicCount,
    'private': privateCount,
    'withImage': withImageCount,
  };
});
