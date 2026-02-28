import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letmegoo/constants/app_images.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/core/error/exceptions.dart';

import 'package:letmegoo/features/vehicle/presentation/screens/owner_not_found_page.dart';
import 'package:letmegoo/core/services/location_service.dart';
import 'package:letmegoo/core/widgets/commonButton.dart';
import 'package:letmegoo/models/report_request.dart';

import 'package:letmegoo/features/vehicle/presentation/screens/vehicle_found_page.dart';
import 'package:letmegoo/features/auth/presentation/widgets/main_app.dart';
import 'package:letmegoo/core/widgets/custom_bottom_nav.dart';

// Import extracted providers
import 'package:letmegoo/features/report/presentation/providers/report_state_provider.dart';
import 'package:letmegoo/features/report/presentation/providers/vehicle_search_provider.dart';
import 'package:letmegoo/features/report/presentation/providers/message_options.dart';

// Import extracted widgets
import 'package:letmegoo/features/report/presentation/widgets/image_picker_dialog.dart';

// Import helpers
import 'package:letmegoo/features/report/presentation/utils/image_picker_helper.dart';
import 'package:letmegoo/core/utils/logger.dart';

// UI Component
class CreateReportPage extends ConsumerStatefulWidget {
  final String? registrationNumber;
  final Function(int)? onNavigate;
  final VoidCallback? onAddPressed;
  final VoidCallback? onParkingPressed; // Add this line

  const CreateReportPage({
    super.key,
    this.registrationNumber,
    this.onNavigate,
    this.onAddPressed,
    this.onParkingPressed, // Add this line
  });

  @override
  ConsumerState<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends ConsumerState<CreateReportPage> {
  final TextEditingController regNumberController = TextEditingController();
  final LocationService _locationService = LocationService();
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();

  bool isAnonymous = true;
  List<File> _images = [];
  bool _isLocationLoading = false;
  MessageOption? selectedMessageOption;
  bool get isReportMode => widget.registrationNumber != null;

  @override
  void initState() {
    super.initState();
    // If registration number is passed, populate the field
    if (widget.registrationNumber != null) {
      regNumberController.text = widget.registrationNumber!;
    }
  }

  @override
  void dispose() {
    regNumberController.dispose();
    super.dispose();
  }

  // Get the final message with vehicle number replaced
  String _getFinalMessage() {
    if (selectedMessageOption == null) return '';

    final vehicleNumber = regNumberController.text.trim();
    return selectedMessageOption!.messageTemplate.replaceAll(
      'XXXX',
      vehicleNumber,
    );
  }

  // Show image source selection dialog using extracted widget
  Future<void> _showImageSourceDialog() async {
    await ImagePickerDialog.show(
      context,
      onCamera: _openCamera,
      onGallerySingle: () => _pickImageFromSource(ImageSource.gallery),
      onGalleryMultiple: _pickMultipleImages,
    );
  }

  // Image picking methods using helper
  Future<void> _openCamera() async {
    try {
      final image = await _imagePickerHelper.pickFromCamera();
      if (image != null) {
        setState(() {
          _images.add(image);
        });
        _showSnackBar('Photo captured and added!', isError: false);
      } else {
        _showSnackBar('Camera was cancelled or failed', isError: false);
      }
    } catch (e) {
      _showSnackBar('Camera error: $e', isError: true);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final image = await _imagePickerHelper.pickFromSource(source);
      if (image != null) {
        setState(() {
          _images.add(image);
        });
        _showSnackBar(
          source == ImageSource.camera
              ? 'Photo captured successfully!'
              : 'Photo selected successfully!',
          isError: false,
        );
      } else {
        _showSnackBar(
          source == ImageSource.camera
              ? 'Camera was cancelled'
              : 'No photo selected',
          isError: false,
        );
      }
    } catch (e) {
      String errorMessage =
          'Failed to ${source == ImageSource.camera ? 'capture' : 'select'} photo: $e';
      _showSnackBar(errorMessage, isError: true);
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final images = await _imagePickerHelper.pickMultipleFromGallery();
      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images);
        });
        _showSnackBar(
          '${images.length} photos added successfully',
          isError: false,
        );
      }
    } catch (e) {
      _showSnackBar('Failed to select photos: ${e.toString()}', isError: true);
    }
  }

  Future<void> _pickImages() async {
    _showImageSourceDialog();
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.darkRed : AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<Position?> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      final result = await _locationService.getCurrentLocation(
        accuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      if (result.isSuccess) {
        return result.position;
      } else {
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
          case LocationErrorType.systemError:
            LocationService.showSystemErrorDialog(
              context,
              message: result.errorMessage,
            );
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
        return null;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return await _locationService.getAddressFromCoordinates(
      latitude,
      longitude,
    );
  }

  void _showFullScreenDialog(
    String title,
    String content, {
    bool isError = false,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog.fullscreen(
            child: Container(
              color: AppColors.background,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 80,
                      color: isError ? AppColors.darkRed : AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: AppFonts.semiBold24(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        content,
                        style: AppFonts.regular16().copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CommonButton(
                        text: "OK",
                        onTap:
                            onOkPressed ??
                            () {
                              Navigator.of(context).pop();
                              if (!isError) {
                                Navigator.of(context).pop();
                              }
                            },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // Enhanced dialog specifically for "own vehicle" error
  void _showOwnVehicleErrorDialog() {
    final screenHeight = MediaQuery.of(context).size.height;

    final isSmallScreen = screenHeight < 600;
    final isLargeScreen = screenHeight > 800;
    final imageSize = isSmallScreen ? 120.0 : (isLargeScreen ? 200.0 : 185.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog.fullscreen(
            child: Container(
              color: AppColors.background,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.reportown,
                      height: imageSize,
                      width: imageSize,
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Oh sorry, you can't report your own vehicle!! you funny user!!",
                        style: AppFonts.regular16().copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CommonButton(
                        text: "OK",
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _handleSearchTap() async {
    // Prevent duplicate taps while already searching
    if (_isLocationLoading) return;

    final regNumber = regNumberController.text.trim();

    if (regNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a registration number"),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    // Show loading immediately so user gets visual feedback
    setState(() {
      _isLocationLoading = true;
    });

    AppLogger.debug('🚀 Initiating vehicle search for: $regNumber');

    try {
      // Get current location for search
      Position? position;
      try {
        final locationResult = await _locationService.getCurrentLocation(
          accuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );

        if (locationResult.isSuccess && locationResult.position != null) {
          position = locationResult.position;
          AppLogger.debug(
            '📍 Got location for search: ${position!.latitude}, ${position.longitude}',
          );
        } else {
          AppLogger.debug('📍 No location available for search');
        }
      } catch (e) {
        AppLogger.debug('⚠️ Location error for search: $e');
      }

      // Search with or without location
      ref
          .read(vehicleSearchProvider.notifier)
          .searchVehicle(
            regNumber,
            latitude: position?.latitude,
            longitude: position?.longitude,
          );
    } finally {
      // Clear location loading - vehicle search provider will show its own loading state
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    }
  }

  void _handleInformTap() async {
    final regNumber = regNumberController.text.trim();

    if (regNumber.isEmpty || selectedMessageOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all required fields"),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    Position? position = await _getCurrentLocation();
    if (position == null) {
      return;
    }

    String location = await _getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final finalMessage = _getFinalMessage();

    final request = ReportRequest(
      vehicleId: regNumber,
      images: _images,
      isAnonymous: isAnonymous,
      notes: finalMessage,
      longitude: position.longitude.toString(),
      latitude: position.latitude.toString(),
      location: location,
    );

    ref.read(reportStateProvider.notifier).reportVehicle(request);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    // Listen to vehicle search state changes
    ref.listen(vehicleSearchProvider, (previous, next) {
      next.when(
        data: (vehicle) {
          if (vehicle != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehicleFoundPage(vehicle: vehicle),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OwnerNotFoundPage()),
            );
          }
        },
        error: (error, stackTrace) {
          _showFullScreenDialog(
            "Error",
            "Failed to search vehicle. Please try again.",
            isError: true,
          );
          ref.read(vehicleSearchProvider.notifier).resetState();
        },
        loading: () {},
      );
    });

    // Enhanced: Listen to report state changes with specific "own vehicle" error handling
    ref.listen<AsyncValue<Map<String, dynamic>?>>(reportStateProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (data) {
          if (data != null) {
            _showFullScreenDialog(
              "Report Submitted",
              "Your report has been submitted successfully. The vehicle owner will be notified.",
              onOkPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MainApp()),
                  (Route<dynamic> route) => false,
                );
              },
            );
            ref.read(reportStateProvider.notifier).resetState();
          }
        },
        error: (error, stackTrace) {
          String errorMessage = error.toString();

          // Check if it's the "own vehicle" error
          if (errorMessage.contains("You cannot report your own vehicle") ||
              errorMessage.contains("FORBIDDEN") ||
              errorMessage.contains("cannot report your own vehicle") ||
              error is ForbiddenException) {
            _showOwnVehicleErrorDialog();
          } else {
            _showFullScreenDialog(
              "Error",
              "Failed to submit report. Please try again.",
              isError: true,
            );
          }
          ref.read(reportStateProvider.notifier).resetState();
        },
        loading: () {},
      );
    });

    final reportState = ref.watch(reportStateProvider);
    final vehicleSearchState = ref.watch(vehicleSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Padding(
                //   padding: EdgeInsets.symmetric(
                //     horizontal: screenWidth * 0.05,
                //     vertical: screenHeight * 0.015,
                //   ),
                //   child: Row(
                //     children: [
                //       Material(
                //         color: Colors.transparent,
                //         child: InkWell(
                //           onTap: _handleReportsButtonTap,
                //           borderRadius: BorderRadius.circular(12),
                //           child: Container(
                //             padding: EdgeInsets.symmetric(
                //               horizontal: screenWidth * 0.035,
                //               vertical: screenHeight * 0.012,
                //             ),
                //             decoration: BoxDecoration(
                //               color: AppColors.primary.withValues(alpha: 0.1),
                //               borderRadius: BorderRadius.circular(12),
                //               border: Border.all(
                //                 color: AppColors.primary.withValues(alpha: 0.3),
                //                 width: 1,
                //               ),
                //             ),
                //             child: Row(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Icon(
                //                   Icons.notifications_active_outlined,
                //                   color: AppColors.primary,
                //                   size:
                //                       screenWidth *
                //                       (isLargeScreen
                //                           ? 0.02
                //                           : isTablet
                //                           ? 0.03
                //                           : 0.05),
                //                 ),
                //                 SizedBox(width: screenWidth * 0.02),
                //                 Text(
                //                   'Reports',
                //                   style: TextStyle(
                //                     fontSize:
                //                         screenWidth *
                //                         (isLargeScreen
                //                             ? 0.014
                //                             : isTablet
                //                             ? 0.022
                //                             : 0.035),
                //                     fontWeight: FontWeight.w600,
                //                     color: AppColors.primary,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       const Spacer(),
                //     ],
                //   ),
                // ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 600 : double.infinity,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.02),
                          Image.asset(
                            AppImages.home,
                            height:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.2
                                    : isTablet
                                    ? 0.25
                                    : 0.55),
                            width:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.2
                                    : isTablet
                                    ? 0.25
                                    : 0.55),
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            isReportMode
                                ? "Inform Owner"
                                : "Let's get the help",
                            textAlign: TextAlign.center,
                            style: AppFonts.semiBold24().copyWith(
                              fontSize:
                                  screenWidth *
                                  (isLargeScreen
                                      ? 0.025
                                      : isTablet
                                      ? 0.035
                                      : 0.065),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Text(
                            isReportMode
                                ? "Fill in the details below so we can alert the\nowner and get things moving quickly."
                                : "Search whether the vehicle owner blocking\nyour way is registered with us or not!",
                            textAlign: TextAlign.center,
                            style: AppFonts.regular14().copyWith(
                              fontSize:
                                  screenWidth *
                                  (isLargeScreen
                                      ? 0.014
                                      : isTablet
                                      ? 0.025
                                      : 0.045),
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          TextField(
                            controller: regNumberController,
                            readOnly: isReportMode,
                            style: TextStyle(
                              fontSize:
                                  screenWidth *
                                  (isLargeScreen
                                      ? 0.016
                                      : isTablet
                                      ? 0.025
                                      : 0.04),
                              color:
                                  isReportMode
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "KL00AA0000",
                              hintStyle: TextStyle(
                                fontSize:
                                    screenWidth *
                                    (isLargeScreen
                                        ? 0.014
                                        : isTablet
                                        ? 0.022
                                        : 0.035),
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              labelText: "Registration Number",
                              labelStyle: TextStyle(
                                fontSize:
                                    screenWidth *
                                    (isLargeScreen
                                        ? 0.014
                                        : isTablet
                                        ? 0.022
                                        : 0.035),
                                color: AppColors.textSecondary,
                              ),
                              filled: isReportMode,
                              fillColor:
                                  isReportMode
                                      ? AppColors.textSecondary.withValues(
                                        alpha: 0.1,
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.02,
                              ),
                            ),
                          ),

                          // Show additional fields only in report mode
                          if (isReportMode) ...[
                            SizedBox(height: screenHeight * 0.025),
                            DropdownButtonFormField<MessageOption>(
                              value: selectedMessageOption,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary,
                              ),
                              // [REMOVED] isExpanded: true is removed to prevent the full-width issue.
                              dropdownColor: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              decoration: InputDecoration(
                                labelText: "Select Message Type",
                                labelStyle: TextStyle(
                                  fontSize:
                                      screenWidth *
                                      (isLargeScreen
                                          ? 0.014
                                          : isTablet
                                          ? 0.022
                                          : 0.035),
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.02,
                                ),
                              ),
                              // [FIX #1] Use selectedItemBuilder to show a simple Text widget when closed
                              selectedItemBuilder: (BuildContext context) {
                                return MessageOption.values.map((
                                  MessageOption option,
                                ) {
                                  return Text(
                                    option.displayText,
                                    // This style ensures it looks like normal text inside the field
                                    style: TextStyle(
                                      fontSize:
                                          screenWidth *
                                          (isLargeScreen
                                              ? 0.016
                                              : isTablet
                                              ? 0.025
                                              : 0.04),
                                      color: AppColors.textPrimary,
                                    ),
                                  );
                                }).toList();
                              },
                              // This builder still provides the nice UI for the open menu
                              items:
                                  MessageOption.values.map((option) {
                                    return DropdownMenuItem<MessageOption>(
                                      value: option,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 4.0,
                                        ),
                                        child: Text(
                                          option.displayText,
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth *
                                                (isLargeScreen
                                                    ? 0.016
                                                    : isTablet
                                                    ? 0.025
                                                    : 0.04),
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (MessageOption? newValue) {
                                setState(() {
                                  selectedMessageOption = newValue;
                                });
                              },
                              hint: Text(
                                "Choose a message type",
                                style: TextStyle(
                                  fontSize:
                                      screenWidth *
                                      (isLargeScreen
                                          ? 0.014
                                          : isTablet
                                          ? 0.022
                                          : 0.035),
                                  color: AppColors.textSecondary.withOpacity(
                                    0.6,
                                  ),
                                ),
                              ),
                            ),

                            // Show message preview if option is selected
                            if (selectedMessageOption != null) ...[
                              SizedBox(height: screenHeight * 0.02),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.preview,
                                          color: AppColors.primary,
                                          size: screenWidth * 0.04,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          'Message Preview:',
                                          style: AppFonts.semiBold14().copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenWidth * 0.02),
                                    Text(
                                      _getFinalMessage(),
                                      style: AppFonts.regular14().copyWith(
                                        color: AppColors.textPrimary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: screenHeight * 0.025),

                            // Add Images Button
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width:
                                    screenWidth *
                                    (isLargeScreen
                                        ? 0.4
                                        : isTablet
                                        ? 0.6
                                        : 0.75),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.018,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.textSecondary,
                                      size:
                                          screenWidth *
                                          (isLargeScreen
                                              ? 0.025
                                              : isTablet
                                              ? 0.035
                                              : 0.055),
                                    ),
                                    SizedBox(width: screenWidth * 0.025),
                                    Text(
                                      "Add images of vehicle",
                                      style: AppFonts.regular16().copyWith(
                                        fontSize:
                                            screenWidth *
                                            (isLargeScreen
                                                ? 0.016
                                                : isTablet
                                                ? 0.025
                                                : 0.04),
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Show selected images
                            if (_images.isNotEmpty) ...[
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Photos (${_images.length})',
                                    style: AppFonts.semiBold16().copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize:
                                          screenWidth *
                                          (isLargeScreen
                                              ? 0.016
                                              : isTablet
                                              ? 0.025
                                              : 0.04),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _images.clear();
                                      });
                                      _showSnackBar(
                                        'All photos removed',
                                        isError: false,
                                      );
                                    },
                                    child: Text(
                                      'Clear All',
                                      style: AppFonts.regular14().copyWith(
                                        color: AppColors.darkRed,
                                        fontSize:
                                            screenWidth *
                                            (isLargeScreen
                                                ? 0.014
                                                : isTablet
                                                ? 0.022
                                                : 0.032),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              SizedBox(
                                height: screenHeight * 0.15,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              _images[index],
                                              height: screenHeight * 0.15,
                                              width: screenHeight * 0.15,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _images.removeAt(index);
                                                });
                                                _showSnackBar(
                                                  'Photo removed',
                                                  isError: false,
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.darkRed
                                                      .withValues(alpha: 0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: AppColors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.7,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

                            SizedBox(height: screenHeight * 0.03),

                            // Anonymous Checkbox
                            Row(
                              children: [
                                Transform.scale(
                                  scale:
                                      isLargeScreen
                                          ? 1.2
                                          : isTablet
                                          ? 1.1
                                          : 1.0,
                                  child: Checkbox(
                                    value: isAnonymous,
                                    onChanged: (val) {
                                      setState(() {
                                        isAnonymous = val ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    checkColor: AppColors.white,
                                    side: BorderSide(
                                      color:
                                          isAnonymous
                                              ? AppColors.primary
                                              : AppColors.textSecondary
                                                  .withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Text(
                                    "Do you want to keep your identity anonymous",
                                    style: AppFonts.regular16().copyWith(
                                      fontSize:
                                          screenWidth *
                                          (isLargeScreen
                                              ? 0.014
                                              : isTablet
                                              ? 0.025
                                              : 0.038),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          SizedBox(height: screenHeight * 0.04),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed Bottom Button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.075,
                    vertical: screenHeight * 0.02,
                  ),
                  child: CommonButton(
                    text: _getButtonText(),
                    onTap: _getButtonAction(),
                  ),
                ),

                // Bottom Navigation (only show if navigation callbacks are provided)
                if (widget.onNavigate != null)
                  CustomBottomNav(
                    currentIndex: 0,
                    onTap: widget.onNavigate!,
                    onInformPressed: widget.onAddPressed ?? () {},
                    onParkingPressed:
                        widget.onParkingPressed ?? () {}, // Add this line
                  ),
              ],
            ),

            // Loading overlay
            if (reportState.isLoading ||
                vehicleSearchState.isLoading ||
                _isLocationLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      if (_isLocationLoading) ...[
                        const SizedBox(height: 16),
                        Text(
                          "Getting your location...",
                          style: AppFonts.regular16().copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    final reportState = ref.watch(reportStateProvider);
    final vehicleSearchState = ref.watch(vehicleSearchProvider);

    if (_isLocationLoading) return "Getting Location...";
    if (reportState.isLoading) return "Submitting...";
    if (vehicleSearchState.isLoading) return "Searching...";

    return isReportMode ? "Inform" : "Search";
  }

  VoidCallback _getButtonAction() {
    final reportState = ref.watch(reportStateProvider);
    final vehicleSearchState = ref.watch(vehicleSearchProvider);

    if (reportState.isLoading ||
        vehicleSearchState.isLoading ||
        _isLocationLoading) {
      return () {};
    }

    return isReportMode ? _handleInformTap : _handleSearchTap;
  }
}
