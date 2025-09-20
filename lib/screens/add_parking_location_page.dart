// lib/screens/add_parking_location_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/parking_location_model.dart';
import 'package:letmegoo/models/vehicle.dart';
import 'package:letmegoo/widgets/commonButton.dart';
import 'package:letmegoo/providers/parking_location_providers.dart';
import 'package:letmegoo/services/location_service.dart';
import 'package:letmegoo/services/auth_service.dart';

// Vehicle provider for this page
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  return await AuthService.getUserVehicles();
});

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
  bool _isSubmitting = false;

  // Vehicle selection state
  Vehicle? _selectedVehicle;
  bool _useManualInput = false;

  final ImagePicker _imagePicker = ImagePicker();
  final LocationService _locationService = LocationService();

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
    try {
      final result = await _locationService.getCurrentLocation(
        accuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      if (result.isSuccess && result.position != null) {
        setState(() {
          _currentPosition = result.position;
        });
        print(
          '📍 Current location: ${result.position!.latitude}, ${result.position!.longitude}',
        );
      } else {
        print('❌ Error getting location: ${result.errorMessage}');
        _handleLocationError(result);
      }
    } catch (e) {
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  String _getVehicleNumber() {
    if (_selectedVehicle != null) {
      return _selectedVehicle!.vehicleNumber;
    }
    return _vehicleNumberController.text.trim();
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

    final vehicleNumber = _getVehicleNumber();
    if (vehicleNumber.isEmpty) {
      _showErrorSnackBar('Please select a vehicle or enter a vehicle number.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = ParkingLocationRequest(
        vehicleNumber: vehicleNumber,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        imagePath: _selectedImage?.path,
        visibility: _selectedVisibility,
      );

      final success = await ref
          .read(parkingLocationProvider.notifier)
          .createLocation(request);

      if (success) {
        _showSuccessSnackBar('Parking location saved successfully!');
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
    final vehiclesAsync = ref.watch(vehiclesProvider);

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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle selection section
                _buildVehicleSelectionSection(vehiclesAsync),
                const SizedBox(height: 20),

                // Notes field
                _buildNotesField(),
                const SizedBox(height: 20),

                // Image section
                _buildImageSection(),
                const SizedBox(height: 30),

                // Submit button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelectionSection(
    AsyncValue<List<Vehicle>> vehiclesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Vehicle *',
          style: AppFonts.semiBold14().copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),

        vehiclesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
          data: (vehicles) => _buildVehicleSelection(vehicles),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading your vehicles...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to load vehicles. Using manual input.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildManualVehicleInput(),
      ],
    );
  }

  Widget _buildVehicleSelection(List<Vehicle> vehicles) {
    if (vehicles.isEmpty || _useManualInput) {
      return Column(
        children: [
          _buildManualVehicleInput(),
          if (vehicles.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildBackToListButton(),
          ],
        ],
      );
    }

    return Column(
      children: [
        _buildVehicleDropdown(vehicles),
        const SizedBox(height: 12),
        _buildAddDifferentVehicleButton(),
      ],
    );
  }

  Widget _buildVehicleDropdown(List<Vehicle> vehicles) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vehicle?>(
          value: _selectedVehicle,
          hint: Row(
            children: [
              Icon(Icons.directions_car, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Select your vehicle',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          isExpanded: true,
          items:
              vehicles.map((vehicle) {
                return DropdownMenuItem<Vehicle?>(
                  value: vehicle,
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vehicle.vehicleNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (vehicle.name.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                vehicle.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (vehicle.isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 16,
                        ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (Vehicle? vehicle) {
            setState(() {
              _selectedVehicle = vehicle;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAddDifferentVehicleButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _useManualInput = true;
          _selectedVehicle = null;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Add Different Vehicle',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToListButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _useManualInput = false;
          _vehicleNumberController.clear();
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Back to Vehicle List',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualVehicleInput() {
    return TextFormField(
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (_selectedVehicle != null) return null;
        if (value == null || value.trim().isEmpty) {
          return 'Vehicle number is required';
        }
        if (value.trim().length < 3) {
          return 'Vehicle number is too short';
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: AppFonts.semiBold14().copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText:
                'Add notes about parking location (e.g., "Near main entrance", "Level 2 parking")',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.note_add),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo (Optional)',
          style: AppFonts.semiBold14().copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),

        if (_selectedImage != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
        ],

        InkWell(
          onTap: _showImagePickerOptions,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedImage != null ? Icons.edit : Icons.add_a_photo,
                  color: AppColors.primary,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImage != null ? 'Change Photo' : 'Add Photo',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to ${_selectedImage != null ? 'change' : 'add'} a photo of your parking area',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child:
          _isSubmitting
              ? Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Saving...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : CommonButton(
                text: "Mark your parking spot",
                onTap: _submitForm,
              ),
    );
  }
}
