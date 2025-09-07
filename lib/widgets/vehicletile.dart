// lib/widgets/vehicletile.dart (Updated to work with Vehicle model)
import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

class Vehicletile extends StatelessWidget {
  final String number;
  final String type;
  final String brand;
  final String model;
  final String? image;
  final bool isVerified;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const Vehicletile({
    super.key,
    required this.number,
    required this.type,
    required this.brand,
    required this.model,
    this.image,
    this.isVerified = false,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Row(
        children: [
          // Vehicle Image
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
              color: AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                image != null && image!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.directions_car,
                            color: AppColors.textSecondary,
                            size:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.04
                                    : isTablet
                                    ? 0.05
                                    : 0.08),
                          );
                        },
                      ),
                    )
                    : Icon(
                      Icons.directions_car,
                      color: AppColors.textSecondary,
                      size:
                          screenWidth *
                          (isLargeScreen
                              ? 0.04
                              : isTablet
                              ? 0.05
                              : 0.08),
                    ),
          ),

          SizedBox(width: screenWidth * 0.04),

          // Vehicle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        number,
                        style: AppFonts.semiBold16().copyWith(
                          fontSize:
                              screenWidth *
                              (isLargeScreen
                                  ? 0.016
                                  : isTablet
                                  ? 0.025
                                  : 0.04),
                        ),
                      ),
                    ),
                    if (isVerified)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenWidth * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: screenWidth * 0.03,
                              color: AppColors.darkGreen,
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              'Verified',
                              style: AppFonts.semiBold14().copyWith(
                                fontSize: screenWidth * 0.025,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  '$brand • $type',
                  style: AppFonts.regular14().copyWith(
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.014
                            : isTablet
                            ? 0.022
                            : 0.035),
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  model,
                  style: AppFonts.regular14().copyWith(
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.014
                            : isTablet
                            ? 0.022
                            : 0.035),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size:
                      screenWidth *
                      (isLargeScreen
                          ? 0.02
                          : isTablet
                          ? 0.03
                          : 0.05),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.darkRed,
                  size:
                      screenWidth *
                      (isLargeScreen
                          ? 0.02
                          : isTablet
                          ? 0.03
                          : 0.05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
