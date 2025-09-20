// lib/widgets/vehicle_display_widget.dart
import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/vehicle.dart';

class VehicleDisplayWidget extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showDetails;
  final double? fontSize;
  final double? iconSize;

  const VehicleDisplayWidget({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.onTap,
    this.showDetails = true,
    this.fontSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultFontSize = fontSize ?? screenWidth * 0.025;
    final defaultIconSize = iconSize ?? screenWidth * 0.025;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
        ),
        child: Row(
          children: [
            // Vehicle icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                color: AppColors.primary,
                size: defaultIconSize,
              ),
            ),

            const SizedBox(width: 12),

            // Vehicle details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vehicle number (always shown)
                  Text(
                    vehicle.vehicleNumber,
                    style: TextStyle(
                      fontSize: defaultFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  if (showDetails) ...[
                    // Vehicle name (if available)
                    if (vehicle.name.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vehicle.name,
                        style: TextStyle(
                          fontSize: defaultFontSize * 0.85,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],

                    // Vehicle type and brand (if available)
                    if (vehicle.vehicleType.isNotEmpty ||
                        vehicle.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (vehicle.brand != null) vehicle.brand!,
                          if (vehicle.vehicleType.isNotEmpty)
                            vehicle.vehicleType,
                        ].join(' • '),
                        style: TextStyle(
                          fontSize: defaultFontSize * 0.8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // Verification badge
            if (vehicle.isVerified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.green,
                      size: defaultIconSize * 0.7,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: defaultFontSize * 0.7,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Selection indicator
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: defaultIconSize,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Compact version for dropdowns
class CompactVehicleDisplayWidget extends StatelessWidget {
  final Vehicle vehicle;
  final double? fontSize;
  final double? iconSize;

  const CompactVehicleDisplayWidget({
    super.key,
    required this.vehicle,
    this.fontSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultFontSize = fontSize ?? screenWidth * 0.025;
    final defaultIconSize = iconSize ?? screenWidth * 0.025;

    return Row(
      children: [
        Icon(
          Icons.directions_car,
          color: AppColors.primary,
          size: defaultIconSize,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vehicle.vehicleNumber,
                style: TextStyle(
                  fontSize: defaultFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (vehicle.name.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  vehicle.name,
                  style: TextStyle(
                    fontSize: defaultFontSize * 0.85,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (vehicle.isVerified)
          Icon(
            Icons.verified,
            color: Colors.green,
            size: defaultIconSize * 0.8,
          ),
      ],
    );
  }
}
