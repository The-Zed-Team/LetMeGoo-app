import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/vehicle.dart';
import 'package:letmegoo/providers/vehicle_provider.dart';
import 'package:letmegoo/providers/app_providers.dart';
import 'package:letmegoo/providers/error_handler_provider.dart';
import '../widgets/deletevehicledialog.dart';
import '../widgets/editvehicledialog.dart';
import '../widgets/addvehicledialog.dart';
import '../widgets/vehicletile.dart';

class MyVehiclesPage extends ConsumerStatefulWidget {
  const MyVehiclesPage({super.key});

  @override
  ConsumerState<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends ConsumerState<MyVehiclesPage> {
  @override
  void initState() {
    super.initState();
    // Load vehicles data on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vehicleProvider.notifier).loadVehicles();
    });
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    try {
      final bool success = await ref
          .read(vehicleProvider.notifier)
          .deleteVehicle(vehicleId);

      if (success) {
        _showSnackBar('Vehicle deleted successfully', isError: false);
      } else {
        _showSnackBar('Failed to delete vehicle', isError: true);
      }
    } catch (e) {
      // Use error handler for consistent error handling
      ErrorHandler.handleError(ref, e, customMessage: 'Error deleting vehicle');
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    // Update global snackbar provider
    ref.read(snackbarProvider.notifier).state = SnackbarMessage(
      message: message,
      isError: isError,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.darkRed : AppColors.darkGreen,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    // Watch vehicle state
    final vehicleState = ref.watch(vehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Vehicles',
          style: AppFonts.bold20().copyWith(
            fontSize:
                screenWidth *
                (isLargeScreen
                    ? 0.022
                    : isTablet
                    ? 0.032
                    : 0.05),
          ),
        ),
        leading: const BackButton(color: AppColors.textPrimary),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showAddVehicleDialog(context);
            },
            icon: Icon(
              Icons.add,
              color: AppColors.primary,
              size:
                  screenWidth *
                  (isLargeScreen
                      ? 0.025
                      : isTablet
                      ? 0.035
                      : 0.06),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(vehicleProvider.notifier).refreshVehicles();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 800 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.08
                                    : isTablet
                                    ? 0.1
                                    : 0.15),
                            height:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.08
                                    : isTablet
                                    ? 0.1
                                    : 0.15),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                screenWidth *
                                    (isLargeScreen
                                        ? 0.04
                                        : isTablet
                                        ? 0.05
                                        : 0.075),
                              ),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: AppColors.primary,
                              size:
                                  screenWidth *
                                  (isLargeScreen
                                      ? 0.04
                                      : isTablet
                                      ? 0.05
                                      : 0.08),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'My Vehicles',
                            style: AppFonts.bold20().copyWith(
                              color: AppColors.textPrimary,
                              fontSize:
                                  screenWidth *
                                  (isLargeScreen
                                      ? 0.022
                                      : isTablet
                                      ? 0.032
                                      : 0.05),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            vehicleState.isLoading
                                ? 'Loading vehicles...'
                                : '${vehicleState.vehicles.length} vehicle${vehicleState.vehicles.length != 1 ? 's' : ''} registered',
                            style: AppFonts.regular14().copyWith(
                              color: AppColors.textSecondary,
                              fontSize:
                                  screenWidth *
                                  (isLargeScreen
                                      ? 0.014
                                      : isTablet
                                      ? 0.025
                                      : 0.035),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Content based on state
                    if (vehicleState.isLoading) ...[
                      _buildLoadingState(screenWidth, screenHeight),
                    ] else if (vehicleState.errorMessage != null) ...[
                      _buildErrorState(
                        screenWidth,
                        screenHeight,
                        vehicleState.errorMessage!,
                      ),
                    ] else if (vehicleState.vehicles.isEmpty) ...[
                      _buildEmptyState(screenWidth, screenHeight),
                    ] else ...[
                      _buildVehiclesList(
                        screenWidth,
                        screenHeight,
                        isTablet,
                        isLargeScreen,
                        vehicleState.vehicles,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Loading your vehicles...',
              style: AppFonts.regular16(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    double screenWidth,
    double screenHeight,
    String errorMessage,
  ) {
    return SizedBox(
      height: screenHeight * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth * 0.15,
              color: AppColors.darkRed,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Failed to load vehicles',
              style: AppFonts.semiBold18(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              errorMessage,
              style: AppFonts.regular14(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed:
                  () => ref.read(vehicleProvider.notifier).refreshVehicles(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: screenWidth * 0.2,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'No vehicles found',
              style: AppFonts.semiBold18(color: AppColors.textPrimary),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Add your first vehicle to get started',
              style: AppFonts.regular14(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton.icon(
              onPressed: () {
                _showAddVehicleDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList(
    double screenWidth,
    double screenHeight,
    bool isTablet,
    bool isLargeScreen,
    List<Vehicle> vehicles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registered Vehicles',
          style: AppFonts.bold16().copyWith(
            color: AppColors.textPrimary,
            fontSize:
                screenWidth *
                (isLargeScreen
                    ? 0.018
                    : isTablet
                    ? 0.028
                    : 0.042),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        ...vehicles.map((vehicle) {
          final String vehicleTypeDisplayMap = ref
              .read(vehicleProvider.notifier)
              .getVehicleTypeDisplay(vehicle.vehicleType);

          // Parse the map string format instead of JSON
          final vehicleTypeDisplay = _parseMapString(vehicleTypeDisplayMap);

          return Container(
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.background, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.withOpacity(0.02)],
                  ),
                ),
                child: Vehicletile(
                  number: vehicle.vehicleNumber,
                  type: vehicleTypeDisplay, // Updated to use provider method
                  brand: vehicle.brand ?? 'Unknown',
                  model: vehicle.name.isNotEmpty ? vehicle.name : 'Vehicle',
                  image: vehicle.imageUrl,
                  isVerified: vehicle.isVerified,
                  onDelete: () => _showDeleteDialog(context, vehicle),
                  onEdit: () => _showEditDialog(context, vehicle),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _parseMapString(String mapString) {
    try {
      // Remove curly braces and split by comma
      final content = mapString.substring(1, mapString.length - 1);
      final pairs = content.split(', ');

      // Find the value pair
      for (final pair in pairs) {
        if (pair.trim().startsWith('value:')) {
          return pair.split(':')[1].trim();
        }
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Addvehicledialog(
            onAdd: (newVehicle) {
              Navigator.pop(context);
              _showSnackBar('Vehicle added successfully!', isError: false);
              // Refresh the vehicles list
              ref.read(vehicleProvider.notifier).refreshVehicles();
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Deletevehicledialog(
            vehicleName: vehicle.name.isNotEmpty ? vehicle.name : null,
            vehicleNumber: vehicle.vehicleNumber,
            onDelete: () {
              _deleteVehicle(vehicle.id);
            },
          ),
    );
  }

  void _showEditDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder:
          (_) => Editvehicledialog(
            vehicle: vehicle,
            onEdit: (updatedVehicle) {
              Navigator.pop(context);
              _showSnackBar('Vehicle updated successfully!', isError: false);
              // Refresh the vehicles list
              ref.read(vehicleProvider.notifier).refreshVehicles();
            },
            onDelete: () {
              Navigator.pop(context);
            },
          ),
    );
  }
}
