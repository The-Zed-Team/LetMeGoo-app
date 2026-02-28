import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/features/vehicle/domain/entities/vehicle.dart';
import 'package:letmegoo/features/vehicle/domain/usecases/update_vehicle.dart';
import 'package:letmegoo/features/vehicle/presentation/providers/vehicle_providers.dart';
import 'package:letmegoo/core/widgets/labeledtextfield.dart';

class Editvehicledialog extends ConsumerStatefulWidget {
  final Vehicle vehicle;
  final Function(Vehicle) onEdit;
  final VoidCallback onDelete;

  const Editvehicledialog({
    super.key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<Editvehicledialog> createState() => _EditvehicledialogState();
}

class _EditvehicledialogState extends ConsumerState<Editvehicledialog> {
  late TextEditingController _registrationController;
  late TextEditingController _brandController;
  late TextEditingController _nameController;

  String? selectedVehicleTypeKey; // Store the key, not the full object
  String? selectedFuelType;
  File? _selectedImage;

  // Fuel types matching server expectations
  final List<Map<String, String>> fuelTypes = [
    {'display': 'Petrol', 'value': 'petrol'},
    {'display': 'Diesel', 'value': 'diesel'},
    {'display': 'Electric', 'value': 'electric'},
    {'display': 'Hybrid', 'value': 'hybrid'},
    {'display': 'CNG', 'value': 'cng'},
    {'display': 'LPG', 'value': 'lpg'},
    {'display': 'Hydrogen', 'value': 'hydrogen'},
    {'display': 'Biofuel', 'value': 'biofuel'},
    {'display': 'Other', 'value': 'other'},
  ];

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _registrationController = TextEditingController(
      text: widget.vehicle.vehicleNumber,
    );
    _brandController = TextEditingController(text: widget.vehicle.brand);
    _nameController = TextEditingController(text: widget.vehicle.name);

    // Initialize vehicle type - use the vehicleType from the entity
    selectedVehicleTypeKey = widget.vehicle.vehicleType;

    // Initialize fuel type
    _initializeFuelType();
  }

  void _initializeFuelType() {
    if (widget.vehicle.fuelType.isNotEmpty) {
      final cleanFuelType = widget.vehicle.fuelType.trim().toLowerCase();

      // Find matching fuel type in our predefined list
      try {
        final matchedFuel = fuelTypes.firstWhere(
          (fuel) => fuel['value']?.toLowerCase() == cleanFuelType,
        );
        selectedFuelType = matchedFuel['value'];
      } catch (e) {
        // If no match, try by display name
        try {
          final matchedFuel = fuelTypes.firstWhere(
            (fuel) => fuel['display']?.toLowerCase() == cleanFuelType,
          );
          selectedFuelType = matchedFuel['value'];
        } catch (e) {
          // No match found, leave as null
          selectedFuelType = null;
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  bool _validateForm() {
    if (selectedVehicleTypeKey == null) {
      _showSnackBar('Please select a vehicle type');
      return false;
    }
    if (_registrationController.text.trim().isEmpty) {
      _showSnackBar('Please enter registration number');
      return false;
    }
    return true;
  }

  Future<void> _updateVehicle() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updateVehicleUseCase = ref.read(updateVehicleUseCaseProvider);

      final params = UpdateVehicleParams(
        vehicleId: widget.vehicle.id,
        vehicleNumber: _registrationController.text.trim(),
        vehicleType: selectedVehicleTypeKey!,
        name:
            _nameController.text.trim().isNotEmpty
                ? _nameController.text.trim()
                : null,
        brand:
            _brandController.text.trim().isNotEmpty
                ? _brandController.text.trim()
                : null,
        fuelType: selectedFuelType,
        image: _selectedImage,
      );

      final updatedVehicle = await updateVehicleUseCase(params);

      // Success
      widget.onEdit(updatedVehicle);
      _showSnackBar('Vehicle updated successfully!', isError: false);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.darkRed : AppColors.darkGreen,
      ),
    );
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _brandController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Watch vehicle types from provider
    final vehicleTypesAsync = ref.watch(vehicleTypesProvider);

    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Center(
        child: Text(
          'Edit Vehicle',
          style: AppFonts.bold18(
            color: AppColors.textPrimary,
          ).copyWith(fontSize: isTablet ? 20 : 18),
          textAlign: TextAlign.center,
        ),
      ),
      content: SizedBox(
        width: isTablet ? 400 : 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Description
              Text(
                "Update your vehicle information below. Vehicle type and registration number are required.",
                style: AppFonts.regular14(
                  color: AppColors.textSecondary,
                ).copyWith(fontSize: isTablet ? 16 : 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// Vehicle Type Dropdown
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Type *',
                      style: AppFonts.regular14(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    vehicleTypesAsync.when(
                      data: (types) {
                        return DropdownButtonFormField<String>(
                          value: selectedVehicleTypeKey,
                          decoration: InputDecoration(
                            hintText: 'Select Vehicle Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          items:
                              types.map((VehicleTypeInfo type) {
                                return DropdownMenuItem<String>(
                                  value: type.key,
                                  child: Text(type.value),
                                );
                              }).toList(),
                          onChanged:
                              _isLoading
                                  ? null
                                  : (value) {
                                    setState(() {
                                      selectedVehicleTypeKey = value;
                                    });
                                  },
                        );
                      },
                      loading:
                          () => Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textSecondary.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      error:
                          (error, stack) => Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.darkRed),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Error loading types',
                                style: TextStyle(color: AppColors.darkRed),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// Registration Number Field
              Labeledtextfield(
                label: "Registration Number *",
                hint: "KL00AA0000",
                controller: _registrationController,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 12),

              /// Vehicle Name Field
              Labeledtextfield(
                label: "Vehicle Name",
                hint: "My Car",
                controller: _nameController,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 12),

              /// Brand Field
              Labeledtextfield(
                label: "Brand",
                hint: "Honda",
                controller: _brandController,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 12),

              /// Fuel Type Dropdown
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel Type',
                      style: AppFonts.regular14(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedFuelType,
                      decoration: InputDecoration(
                        hintText: 'Select Fuel Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.textSecondary.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items:
                          fuelTypes.map((Map<String, String> fuel) {
                            return DropdownMenuItem<String>(
                              value: fuel['value'],
                              child: Text(fuel['display']!),
                            );
                          }).toList(),
                      onChanged:
                          _isLoading
                              ? null
                              : (value) {
                                setState(() {
                                  selectedFuelType = value;
                                });
                              },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Add Image Button
              SizedBox(
                width: 250,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: Icon(
                    _selectedImage != null
                        ? Icons.check_circle
                        : Icons.image_outlined,
                    color:
                        _selectedImage != null
                            ? AppColors.darkGreen
                            : AppColors.textPrimary,
                  ),
                  label: Text(
                    _selectedImage != null
                        ? "Image Selected"
                        : "Add an image of vehicle",
                    style: TextStyle(
                      color:
                          _selectedImage != null
                              ? AppColors.darkGreen
                              : AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color:
                          _selectedImage != null
                              ? AppColors.darkGreen
                              : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    foregroundColor:
                        _selectedImage != null
                            ? AppColors.darkGreen
                            : AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.textPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppFonts.regular14(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateVehicle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  "Update Vehicle",
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
