// lib/screens/add_parking_location_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/parking_location_model.dart';
import 'package:letmegoo/widgets/commonButton.dart';
import 'package:letmegoo/providers/parking_location_providers.dart';
import 'package:letmegoo/services/location_service.dart';

class AddParkingLocationPage extends ConsumerStatefulWidget {
  const AddParkingLocationPage({super.key});

  @override
  ConsumerState<AddParkingLocationPage> createState() =>
      _AddParkingLocationPageState();
}

class _AddParkingLocationPageState
    extends ConsumerState<AddParkingLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVisibility = 'public';
  File? _selectedImage;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();
  final LocationService _locationService = LocationService(); // Create instance

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final result = await _locationService.getCurrentLocation(
        accuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      if (result.isSuccess && result.position != null) {
        setState(() {
          _currentPosition = result.position;
          _isLoadingLocation = false;
        });
        print(
          '📍 Current location: ${result.position!.latitude}, ${result.position!.longitude}',
        );
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
        print('❌ Error getting location: ${result.errorMessage}');
        _handleLocationError(result);
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('❌ Exception getting location: $e');
      _showErrorSnackBar('Failed to get current location. Please try again.');
    }
  }

  void _handleLocationError(LocationResult result) {
    switch (result.errorType) {
      case LocationErrorType.serviceDisabled:
        _showErrorSnackBar(
          'Location services are disabled. Please enable location services.',
        );
        break;
      case LocationErrorType.permissionDenied:
        _showErrorSnackBar(
          'Location permission denied. Please allow location access.',
        );
        break;
      case LocationErrorType.permissionPermanentlyDenied:
        _showErrorSnackBar(
          'Location permission permanently denied. Please enable in settings.',
        );
        break;
      case LocationErrorType.locationError:
        _showErrorSnackBar(result.errorMessage ?? 'Error getting location.');
        break;
      case LocationErrorType.systemError:
        _showErrorSnackBar(
          result.errorMessage ?? 'System error getting location.',
        );
        break;
      default:
        _showErrorSnackBar('Failed to get current location. Please try again.');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print('📸 Image selected: ${pickedFile.path}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      _showErrorSnackBar('Failed to pick image. Please try again.');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Remove Image',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPosition == null) {
      _showErrorSnackBar(
        'Location not available. Please wait for location to load or try again.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = ParkingLocationRequest(
        vehicleNumber: _vehicleNumberController.text.trim(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        imagePath: _selectedImage?.path,
        visibility: _selectedVisibility,
      );

      print('🚗 Submitting parking location...');
      print('  - Vehicle: ${request.vehicleNumber}');
      print('  - Location: ${request.latitude}, ${request.longitude}');
      print('  - Visibility: ${request.visibility}');
      print('  - Has image: ${request.imagePath != null}');
      print('  - Notes: ${request.notes ?? 'None'}');

      final success = await ref
          .read(parkingLocationProvider.notifier)
          .createLocation(request);

      if (success) {
        _showSuccessSnackBar('Parking location saved successfully!');
        // Return to previous screen with success indicator
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(
          'Failed to save parking location. Please try again.',
        );
      }
    } catch (e) {
      print('❌ Error submitting form: $e');
      _showErrorSnackBar('An error occurred while saving. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Navigate to your vehicle', style: AppFonts.semiBold20()),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location status
              _buildLocationStatus(screenWidth, isTablet),

              SizedBox(height: screenHeight * 0.03),

              // Vehicle number field
              _buildVehicleNumberField(screenWidth, isTablet),

              SizedBox(height: screenHeight * 0.02),

              // Notes field
              _buildNotesField(screenWidth, isTablet),

              SizedBox(height: screenHeight * 0.02),

              // Visibility selection
              _buildVisibilitySelection(screenWidth, isTablet),

              SizedBox(height: screenHeight * 0.02),

              // Image section
              _buildImageSection(screenWidth, isTablet),

              SizedBox(height: screenHeight * 0.04),

              // Submit button
              _buildSubmitButton(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStatus(double screenWidth, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: _currentPosition != null ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _currentPosition != null
                  ? Colors.green[200]!
                  : Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (_isLoadingLocation)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else
            Icon(
              _currentPosition != null ? Icons.location_on : Icons.location_off,
              color:
                  _currentPosition != null
                      ? Colors.green[700]
                      : Colors.orange[700],
              size: 20,
            ),

          SizedBox(width: screenWidth * 0.03),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingLocation
                      ? 'Getting your location...'
                      : _currentPosition != null
                      ? 'Location detected'
                      : 'Location not available',
                  style: AppFonts.semiBold14().copyWith(
                    color:
                        _isLoadingLocation
                            ? AppColors.primary
                            : _currentPosition != null
                            ? Colors.green[700]
                            : Colors.orange[700],
                  ),
                ),
                if (_currentPosition != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: AppFonts.regular13().copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (!_isLoadingLocation && _currentPosition == null)
            TextButton(
              onPressed: _getCurrentLocation,
              child: Text(
                'Retry',
                style: AppFonts.semiBold13().copyWith(
                  color: Colors.orange[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVehicleNumberField(double screenWidth, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Number *',
          style: AppFonts.semiBold14().copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _vehicleNumberController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter vehicle number (e.g., KL-01-AB-1234)',
            prefixIcon: Icon(Icons.directions_car, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.035,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vehicle number is required';
            }
            if (value.trim().length < 3) {
              return 'Vehicle number is too short';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesField(double screenWidth, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: AppFonts.semiBold14().copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText:
                'Add notes about parking location (e.g., "Near main entrance", "Level 2 parking")',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(Icons.note_add, color: AppColors.primary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.035,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySelection(double screenWidth, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visibility',
          style: AppFonts.semiBold14().copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 12),

        RadioListTile<String>(
          value: 'public',
          groupValue: _selectedVisibility,
          onChanged: (value) {
            setState(() {
              _selectedVisibility = value!;
            });
          },
          title: const Text('Public'),
          subtitle: const Text('Visible to all users'),
          secondary: Icon(Icons.public, color: AppColors.primary),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),

        RadioListTile<String>(
          value: 'private',
          groupValue: _selectedVisibility,
          onChanged: (value) {
            setState(() {
              _selectedVisibility = value!;
            });
          },
          title: const Text('Private'),
          subtitle: const Text('Only visible to you'),
          secondary: Icon(Icons.lock, color: AppColors.primary),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildImageSection(double screenWidth, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo (Optional)',
          style: AppFonts.semiBold14().copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8),

        if (_selectedImage != null) ...[
          // Display selected image
          Container(
            width: double.infinity,
            height: screenWidth * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 12),
        ],

        // Image picker button
        InkWell(
          onTap: _showImagePickerOptions,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedImage != null ? Icons.edit : Icons.add_a_photo,
                  color: AppColors.primary,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  _selectedImage != null ? 'Change Photo' : 'Add Photo',
                  style: AppFonts.semiBold14().copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap to ${_selectedImage != null ? 'change' : 'add'} a photo of your parking area',
                  style: AppFonts.regular13().copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child:
          _isSubmitting
              ? Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Saving...',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : CommonButton(
                text: "⁠Mark your parking spot",
                onTap: () => _submitForm(),
              ),
    );
  }
}
