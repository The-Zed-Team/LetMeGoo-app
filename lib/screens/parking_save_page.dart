import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/providers/parking_location_providers.dart';
import 'package:letmegoo/widgets/parking_location_card.dart';
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

      if (!cache.isCacheValid || currentState.totalLocations == 0) {
        locationsNotifier
            .loadLocations()
            .then((_) {
              if (mounted) {
                cache.updateCacheTime();
              }
            })
            .catchError((error) {
              if (mounted) {
                _showErrorSnackBar(
                  'Failed to load parking locations. Please try again.',
                );
              }
            });
      }
    } catch (e) {
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
      final locationsNotifier = ref.read(parkingLocationProvider.notifier);
      final cache = ref.read(parkingLocationCacheProvider.notifier);

      await locationsNotifier.refresh();
      if (mounted) {
        cache.updateCacheTime();

        _showSuccessSnackBar('Parking locations refreshed successfully');
      }
    } catch (e) {
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

    // Responsive breakpoints following project patterns
    final bool isLargeScreen = screenWidth > 1200;
    final bool isTablet = screenWidth > 600 && screenWidth <= 1200;

    // Responsive dimensions
    final horizontalPadding =
        screenWidth *
        (isLargeScreen
            ? 0.05
            : isTablet
            ? 0.04
            : 0.02);

    final maxContentWidth = isLargeScreen ? 1000.0 : screenWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size:
                screenWidth *
                (isLargeScreen
                    ? 0.025
                    : isTablet
                    ? 0.035
                    : 0.06),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Navigate to your vehicle',
          style: AppFonts.semiBold20().copyWith(
            fontSize:
                screenWidth *
                (isLargeScreen
                    ? 0.022
                    : isTablet
                    ? 0.032
                    : 0.05),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              children: [
                // Error banner
                Consumer(
                  builder: (context, ref, child) {
                    final locationsState = ref.watch(parkingLocationProvider);
                    if (locationsState.error != null &&
                        locationsState.error!.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: screenHeight * 0.01,
                        ),
                        padding: EdgeInsets.all(
                          screenWidth *
                              (isLargeScreen
                                  ? 0.01
                                  : isTablet
                                  ? 0.015
                                  : 0.02),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(
                            isLargeScreen ? 12 : 8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size:
                                  screenWidth *
                                  (isLargeScreen
                                      ? 0.015
                                      : isTablet
                                      ? 0.02
                                      : 0.025),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Text(
                                locationsState.error!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize:
                                      screenWidth *
                                      (isLargeScreen
                                          ? 0.012
                                          : isTablet
                                          ? 0.018
                                          : 0.025),
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
                                  fontSize:
                                      screenWidth *
                                      (isLargeScreen
                                          ? 0.01
                                          : isTablet
                                          ? 0.016
                                          : 0.022),
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

                // Main content
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final locationsState = ref.watch(parkingLocationProvider);
                      final stats = ref.watch(parkingLocationStatsProvider);

                      if (locationsState.isLoading &&
                          locationsState.hasNoLocations) {
                        return _LoadingWidget(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLargeScreen: isLargeScreen,
                          isTablet: isTablet,
                        );
                      }

                      if (locationsState.error != null &&
                          locationsState.hasNoLocations) {
                        return _ErrorWidget(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLargeScreen: isLargeScreen,
                          isTablet: isTablet,
                          errorMessage: locationsState.error!,
                          onRetry: _retryLoadingLocations,
                        );
                      }

                      if (locationsState.hasNoLocations) {
                        return _EmptyWidget(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLargeScreen: isLargeScreen,
                          isTablet: isTablet,
                          onRefresh: _onRefresh,
                          onAdd: _navigateToAddLocation,
                        );
                      }

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
                            horizontal: horizontalPadding,
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLocation,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
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
    final verticalSpacing =
        screenHeight *
        (isLargeScreen
            ? 0.02
            : isTablet
            ? 0.015
            : 0.01);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: verticalSpacing),

        // Refreshing indicator
        if (isRefreshing) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              screenWidth *
                  (isLargeScreen
                      ? 0.01
                      : isTablet
                      ? 0.015
                      : 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width:
                      screenWidth *
                      (isLargeScreen
                          ? 0.012
                          : isTablet
                          ? 0.018
                          : 0.025),
                  height:
                      screenWidth *
                      (isLargeScreen
                          ? 0.012
                          : isTablet
                          ? 0.018
                          : 0.025),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF31C5F4),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  'Refreshing parking locations...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.01
                            : isTablet
                            ? 0.016
                            : 0.022),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Locations list
        if (locations.isNotEmpty) ...[_buildLocationsSection()],

        SizedBox(height: verticalSpacing),
      ],
    );
  }

  Widget _buildLocationsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal:
            screenWidth *
            (isLargeScreen
                ? 0.02
                : isTablet
                ? 0.03
                : 0.04),
        vertical:
            screenWidth *
            (isLargeScreen
                ? 0.02
                : isTablet
                ? 0.03
                : 0.04),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
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
                        ? 0.025
                        : 0.038),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height:
                screenWidth *
                (isLargeScreen
                    ? 0.015
                    : isTablet
                    ? 0.02
                    : 0.025),
          ),

          // Locations list with responsive spacing
          ...locations.map(
            (location) => Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                vertical:
                    screenWidth *
                    (isLargeScreen
                        ? 0.008
                        : isTablet
                        ? 0.01
                        : 0.015),
              ),
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
  final double screenWidth;
  final double screenHeight;
  final bool isLargeScreen;
  final bool isTablet;

  const _LoadingWidget({
    required this.screenWidth,
    required this.screenHeight,
    required this.isLargeScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.88,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width:
                  screenWidth *
                  (isLargeScreen
                      ? 0.03
                      : isTablet
                      ? 0.04
                      : 0.06),
              height:
                  screenWidth *
                  (isLargeScreen
                      ? 0.03
                      : isTablet
                      ? 0.04
                      : 0.06),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF31C5F4)),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Loading parking locations...',
              style: TextStyle(
                fontSize:
                    screenWidth *
                    (isLargeScreen
                        ? 0.014
                        : isTablet
                        ? 0.02
                        : 0.028),
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
  final double screenWidth;
  final double screenHeight;
  final bool isLargeScreen;
  final bool isTablet;
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.screenWidth,
    required this.screenHeight,
    required this.isLargeScreen,
    required this.isTablet,
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
          padding: EdgeInsets.all(
            screenWidth *
                (isLargeScreen
                    ? 0.03
                    : isTablet
                    ? 0.04
                    : 0.06),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size:
                    screenWidth *
                    (isLargeScreen
                        ? 0.04
                        : isTablet
                        ? 0.06
                        : 0.08),
                color: Colors.red[400],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize:
                      screenWidth *
                      (isLargeScreen
                          ? 0.016
                          : isTablet
                          ? 0.024
                          : 0.032),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize:
                      screenWidth *
                      (isLargeScreen
                          ? 0.012
                          : isTablet
                          ? 0.018
                          : 0.025),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size:
                      screenWidth *
                      (isLargeScreen
                          ? 0.015
                          : isTablet
                          ? 0.02
                          : 0.025),
                ),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.012
                            : isTablet
                            ? 0.018
                            : 0.025),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31C5F4),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth *
                        (isLargeScreen
                            ? 0.025
                            : isTablet
                            ? 0.035
                            : 0.06),
                    vertical:
                        screenWidth *
                        (isLargeScreen
                            ? 0.01
                            : isTablet
                            ? 0.015
                            : 0.025),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
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
  final double screenWidth;
  final double screenHeight;
  final bool isLargeScreen;
  final bool isTablet;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;

  const _EmptyWidget({
    required this.screenWidth,
    required this.screenHeight,
    required this.isLargeScreen,
    required this.isTablet,
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
          padding: EdgeInsets.all(
            screenWidth *
                (isLargeScreen
                    ? 0.03
                    : isTablet
                    ? 0.04
                    : 0.06),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width:
                    screenWidth *
                    (isLargeScreen
                        ? 0.4
                        : isTablet
                        ? 0.5
                        : 0.6),
                height:
                    screenWidth *
                    (isLargeScreen
                        ? 0.25
                        : isTablet
                        ? 0.3
                        : 0.4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                ),
                child: Icon(
                  Icons.local_parking_outlined,
                  size:
                      screenWidth *
                      (isLargeScreen
                          ? 0.12
                          : isTablet
                          ? 0.15
                          : 0.2),
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Sorry, you didn't marked any parking",
                style: AppFonts.bold20().copyWith(
                  fontSize:
                      screenWidth *
                      (isLargeScreen
                          ? 0.018
                          : isTablet
                          ? 0.028
                          : 0.038),
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Save your parking locations to easily find them later',
                style: AppFonts.regular14().copyWith(
                  fontSize:
                      screenWidth *
                      (isLargeScreen
                          ? 0.012
                          : isTablet
                          ? 0.018
                          : 0.025),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),

              // Add parking location button
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: Icon(
                  Icons.add_location,
                  color: Colors.white,
                  size:
                      screenWidth *
                      (isLargeScreen
                          ? 0.015
                          : isTablet
                          ? 0.02
                          : 0.025),
                ),
                label: Text(
                  "Mark your parking spot",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.012
                            : isTablet
                            ? 0.018
                            : 0.025),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31C5F4),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth *
                        (isLargeScreen
                            ? 0.025
                            : isTablet
                            ? 0.035
                            : 0.06),
                    vertical:
                        screenWidth *
                        (isLargeScreen
                            ? 0.01
                            : isTablet
                            ? 0.015
                            : 0.025),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Refresh button
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: Icon(
                  Icons.refresh,
                  color: const Color(0xFF31C5F4),
                  size:
                      screenWidth *
                      (isLargeScreen
                          ? 0.015
                          : isTablet
                          ? 0.02
                          : 0.025),
                ),
                label: Text(
                  'Refresh',
                  style: TextStyle(
                    color: const Color(0xFF31C5F4),
                    fontWeight: FontWeight.bold,
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.012
                            : isTablet
                            ? 0.018
                            : 0.025),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF31C5F4)),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth *
                        (isLargeScreen
                            ? 0.025
                            : isTablet
                            ? 0.035
                            : 0.06),
                    vertical:
                        screenWidth *
                        (isLargeScreen
                            ? 0.01
                            : isTablet
                            ? 0.015
                            : 0.025),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
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
