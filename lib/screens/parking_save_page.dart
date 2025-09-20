// lib/screens/parking_save_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/providers/parking_location_providers.dart';
import 'package:letmegoo/widgets/parking_location_card.dart';
import 'package:letmegoo/widgets/builddivider.dart';
import 'package:letmegoo/screens/add_parking_location_page.dart';

class ParkingSavePage extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onAddPressed;

  const ParkingSavePage({super.key, this.onNavigate, this.onAddPressed});

  @override
  ConsumerState<ParkingSavePage> createState() => _ParkingSavePageState();
}

class _ParkingSavePageState extends ConsumerState<ParkingSavePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocationsIfNeeded();
    });
  }

  Future<void> _loadLocationsIfNeeded() async {
    try {
      final cache = ref.read(parkingLocationCacheProvider.notifier);
      final locationsNotifier = ref.read(parkingLocationProvider.notifier);
      final currentState = ref.read(parkingLocationProvider);

      print('🔍 Loading parking locations check:');
      print('  - Cache valid: ${cache.isCacheValid}');
      print('  - Total locations: ${currentState.totalLocations}');
      print('  - Is loading: ${currentState.isLoading}');
      print('  - Has error: ${currentState.error != null}');

      if (!cache.isCacheValid || currentState.totalLocations == 0) {
        print('🔥 Starting to load parking locations...');
        locationsNotifier
            .loadLocations()
            .then((_) {
              if (mounted) {
                cache.updateCacheTime();
                final newState = ref.read(parkingLocationProvider);
                print('✅ Parking locations loaded successfully:');
                print('  - Total locations: ${newState.totalLocations}');
              }
            })
            .catchError((error) {
              print('❌ Error loading parking locations: $error');
              if (mounted) {
                _showErrorSnackBar(
                  'Failed to load parking locations. Please try again.',
                );
              }
            });
      } else {
        print('✅ Using cached parking locations');
      }
    } catch (e) {
      print('❌ Exception in _loadLocationsIfNeeded: $e');
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred.');
      }
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      print('🔄 Refreshing parking locations...');
      final locationsNotifier = ref.read(parkingLocationProvider.notifier);
      final cache = ref.read(parkingLocationCacheProvider.notifier);

      await locationsNotifier.refresh();
      if (mounted) {
        cache.updateCacheTime();
        final newState = ref.read(parkingLocationProvider);
        print('✅ Parking locations refreshed:');
        print('  - Total: ${newState.totalLocations}');
        _showSuccessSnackBar('Parking locations refreshed successfully');
      }
    } catch (e) {
      print('❌ Error refreshing: $e');
      if (mounted) {
        _showErrorSnackBar(
          'Failed to refresh parking locations. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _loadLocationsIfNeeded(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _retryLoadingLocations() {
    ref.read(parkingLocationProvider.notifier).clearError();
    _loadLocationsIfNeeded();
  }

  void _navigateToAddLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddParkingLocationPage()),
    );

    // If a location was added successfully, refresh the list
    if (result == true) {
      _onRefresh();
    }
  }

  void _deleteLocation(String locationId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Parking Location'),
            content: const Text(
              'Are you sure you want to delete this parking location? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final success = await ref
                        .read(parkingLocationProvider.notifier)
                        .deleteLocation(locationId);

                    if (success) {
                      _showSuccessSnackBar(
                        'Parking location deleted successfully',
                      );
                    } else {
                      _showErrorSnackBar('Failed to delete parking location');
                    }
                  } catch (e) {
                    _showErrorSnackBar('Error deleting parking location');
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _viewLocationOnMap(double latitude, double longitude) {
    // TODO: Implement map view functionality
    // You can integrate with Google Maps, Apple Maps, or a custom map widget
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location'),
            content: Text(
              'Latitude: ${latitude.toStringAsFixed(6)}\nLongitude: ${longitude.toStringAsFixed(6)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),

        title: Text('Saved Parking Areas', style: AppFonts.semiBold20()),
        centerTitle: true,
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: SafeArea(
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final locationsState = ref.watch(parkingLocationProvider);
                  if (locationsState.error != null &&
                      locationsState.error!.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationsState.error!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _retryLoadingLocations,
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final locationsState = ref.watch(parkingLocationProvider);
                    final stats = ref.watch(parkingLocationStatsProvider);

                    print('🎨 Building UI with state:');
                    print('  - Loading: ${locationsState.isLoading}');
                    print(
                      '  - Has no locations: ${locationsState.hasNoLocations}',
                    );
                    print('  - Error: ${locationsState.error}');

                    if (locationsState.isLoading &&
                        locationsState.hasNoLocations) {
                      print('🔄 Showing loading widget');
                      return _LoadingWidget(screenHeight: screenHeight);
                    }

                    if (locationsState.error != null &&
                        locationsState.hasNoLocations) {
                      print('❌ Showing error widget');
                      return _ErrorWidget(
                        screenHeight: screenHeight,
                        errorMessage: locationsState.error!,
                        onRetry: _retryLoadingLocations,
                      );
                    }

                    if (locationsState.hasNoLocations) {
                      print('🔭 Showing empty widget');
                      return _EmptyWidget(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        onRefresh: _onRefresh,
                        onAdd: _navigateToAddLocation,
                      );
                    }

                    print('📊 Showing parking locations content');
                    final formattedLocations = ref.watch(
                      parkingLocationFormattedProvider,
                    );

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: const Color(0xFF31C5F4),
                      backgroundColor: Colors.white,
                      strokeWidth: 2.0,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isLargeScreen ? 900 : double.infinity,
                            minHeight: screenHeight * 0.7,
                          ),
                          child: _ParkingLocationsContent(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isTablet: isTablet,
                            isLargeScreen: isLargeScreen,
                            locations: formattedLocations,
                            stats: stats,
                            isRefreshing: _isRefreshing,
                            onDelete: _deleteLocation,
                            onViewLocation: _viewLocationOnMap,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating action button for adding new location
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLocation,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _ParkingLocationsContent extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isLargeScreen;
  final List<Map<String, dynamic>> locations;
  final Map<String, int> stats;
  final bool isRefreshing;
  final Function(String) onDelete;
  final Function(double, double) onViewLocation;

  const _ParkingLocationsContent({
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isLargeScreen,
    required this.locations,
    required this.stats,
    this.isRefreshing = false,
    required this.onDelete,
    required this.onViewLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRefreshing) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF31C5F4),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Refreshing parking locations...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],

        // Statistics section
        _buildStatsSection(),

        SizedBox(height: screenHeight * 0.02),
        buildDivider(screenWidth),
        SizedBox(height: screenHeight * 0.02),

        // Locations list
        if (locations.isNotEmpty) ...[_buildLocationsSection()],

        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Text(
              "Parking Statistics",
              style: AppFonts.bold16().copyWith(
                fontSize:
                    screenWidth *
                    (isLargeScreen
                        ? 0.018
                        : isTablet
                        ? 0.028
                        : 0.045),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.03),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Locations',
                  stats['total']?.toString() ?? '0',
                  Icons.location_on,
                  const Color(0xFF31C5F4),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _buildStatCard(
                  'Public',
                  stats['public']?.toString() ?? '0',
                  Icons.public,
                  Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.03),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Private',
                  stats['private']?.toString() ?? '0',
                  Icons.lock,
                  Colors.orange,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _buildStatCard(
                  'With Images',
                  stats['withImage']?.toString() ?? '0',
                  Icons.image,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: screenWidth * (isTablet ? 0.035 : 0.05),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value,
            style: AppFonts.bold18().copyWith(
              color: color,
              fontSize: screenWidth * (isTablet ? 0.03 : 0.045),
            ),
          ),
          SizedBox(height: screenWidth * 0.005),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: screenWidth * (isTablet ? 0.02 : 0.025),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Text(
              "Saved Parking Areas (${locations.length})",
              style: AppFonts.bold16().copyWith(
                fontSize:
                    screenWidth *
                    (isLargeScreen
                        ? 0.018
                        : isTablet
                        ? 0.028
                        : 0.045),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),

          // Locations list
          ...locations.map(
            (location) => Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
              child: ParkingLocationCard(
                id: location['id'] ?? '',
                vehicleNumber: location['vehicleNumber'] ?? 'Unknown',
                notes: location['notes'] ?? 'No notes',
                timeDate: location['timeDate'] ?? 'Unknown time',
                location: location['location'] ?? 'Unknown location',
                visibility: location['visibility'] ?? 'public',
                hasImage: location['hasImage'] ?? false,
                imageUrl: location['image'],
                latitude: location['latitude'] ?? 0.0,
                longitude: location['longitude'] ?? 0.0,
                user: location['user'] ?? 'Unknown User',
                userImage: location['userImage'],
                onDelete: () => onDelete(location['id'] ?? ''),
                onViewLocation:
                    () => onViewLocation(
                      location['latitude'] ?? 0.0,
                      location['longitude'] ?? 0.0,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  final double screenHeight;

  const _LoadingWidget({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.88,
      width: double.infinity,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF31C5F4)),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading parking locations...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final double screenHeight;
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.screenHeight,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.88,
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31C5F4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;

  const _EmptyWidget({
    required this.screenHeight,
    required this.screenWidth,
    required this.onRefresh,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.88,
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.local_parking_outlined,
                  size: screenWidth * 0.2,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Parking Areas Saved',
                style: AppFonts.bold20().copyWith(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Save your parking locations to easily find them later',
                style: AppFonts.regular14().copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Add parking location button
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_location, color: Colors.white),
                label: const Text(
                  'Add Parking Area',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31C5F4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Refresh button
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Color(0xFF31C5F4)),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: Color(0xFF31C5F4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF31C5F4)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
