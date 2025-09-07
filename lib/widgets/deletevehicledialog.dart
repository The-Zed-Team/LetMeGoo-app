import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

class Deletevehicledialog extends StatefulWidget {
  final String? vehicleName;
  final String? vehicleNumber;
  final VoidCallback onDelete;

  const Deletevehicledialog({
    super.key,
    this.vehicleName,
    this.vehicleNumber,
    required this.onDelete,
  });

  @override
  State<Deletevehicledialog> createState() => _DeletevehicledialogState();
}

class _DeletevehicledialogState extends State<Deletevehicledialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Close the dialog first
      Navigator.pop(context);

      // Then execute the delete callback
      widget.onDelete();
    } catch (e) {
      // If there's an error, show it and reset loading state
      setState(() {
        _isDeleting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete vehicle: ${e.toString()}'),
          backgroundColor: AppColors.darkRed,
        ),
      );
    }
  }

  String get _vehicleDisplayName {
    if (widget.vehicleName != null && widget.vehicleName!.isNotEmpty) {
      return widget.vehicleName!;
    } else if (widget.vehicleNumber != null &&
        widget.vehicleNumber!.isNotEmpty) {
      return widget.vehicleNumber!;
    } else {
      return 'this vehicle';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              isLargeScreen
                  ? 400
                  : isTablet
                  ? 350
                  : double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenWidth * 0.06,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
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
                  color: AppColors.darkRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_outlined,
                  color: AppColors.darkRed,
                  size:
                      screenWidth *
                      (isLargeScreen
                          ? 0.04
                          : isTablet
                          ? 0.05
                          : 0.08),
                ),
              ),

              SizedBox(height: screenWidth * 0.04),

              // Title
              Text(
                "Delete Vehicle?",
                textAlign: TextAlign.center,
                style: AppFonts.bold20().copyWith(
                  fontSize:
                      screenWidth *
                      (isLargeScreen
                          ? 0.022
                          : isTablet
                          ? 0.032
                          : 0.05),
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: screenWidth * 0.02),

              // Vehicle info if available
              if (widget.vehicleNumber != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.darkRed.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: AppColors.darkRed,
                            size:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.02
                                    : isTablet
                                    ? 0.03
                                    : 0.05),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Flexible(
                            child: Text(
                              widget.vehicleNumber!,
                              style: AppFonts.semiBold16().copyWith(
                                fontSize:
                                    screenWidth *
                                    (isLargeScreen
                                        ? 0.016
                                        : isTablet
                                        ? 0.025
                                        : 0.04),
                                color: AppColors.darkRed,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (widget.vehicleName != null &&
                          widget.vehicleName!.isNotEmpty &&
                          widget.vehicleName != widget.vehicleNumber) ...[
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          widget.vehicleName!,
                          style: AppFonts.regular14().copyWith(
                            fontSize:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.014
                                    : isTablet
                                    ? 0.02
                                    : 0.035),
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
              ],

              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppFonts.regular14().copyWith(
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.014
                            : isTablet
                            ? 0.025
                            : 0.035),
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: "Are you sure you want to delete "),
                    TextSpan(
                      text: _vehicleDisplayName,
                      style: AppFonts.semiBold14().copyWith(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.014
                                : isTablet
                                ? 0.025
                                : 0.035),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: "?"),
                  ],
                ),
              ),

              SizedBox(height: screenWidth * 0.02),

              Text(
                "This action cannot be undone. The vehicle will be permanently removed from your profile.",
                textAlign: TextAlign.center,
                style: AppFonts.regular14().copyWith(
                  fontSize:
                      screenWidth *
                      (isLargeScreen
                          ? 0.012
                          : isTablet
                          ? 0.022
                          : 0.032),
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: screenWidth * 0.06),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: SizedBox(
                      height:
                          screenWidth *
                          (isLargeScreen
                              ? 0.05
                              : isTablet
                              ? 0.06
                              : 0.12),
                      child: OutlinedButton(
                        onPressed:
                            _isDeleting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                _isDeleting
                                    ? AppColors.textSecondary.withOpacity(0.3)
                                    : AppColors.textSecondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppFonts.regular14().copyWith(
                            fontSize:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.014
                                    : isTablet
                                    ? 0.025
                                    : 0.035),
                            color:
                                _isDeleting
                                    ? AppColors.textSecondary.withOpacity(0.5)
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.03),

                  // Delete Button
                  Expanded(
                    child: SizedBox(
                      height:
                          screenWidth *
                          (isLargeScreen
                              ? 0.05
                              : isTablet
                              ? 0.06
                              : 0.12),
                      child: ElevatedButton(
                        onPressed: _isDeleting ? null : _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isDeleting
                                  ? AppColors.darkRed.withOpacity(0.7)
                                  : AppColors.darkRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isDeleting
                                ? SizedBox(
                                  width: screenWidth * 0.04,
                                  height: screenWidth * 0.04,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  "Delete",
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.regular14(
                                    color: AppColors.white,
                                  ).copyWith(
                                    fontSize:
                                        screenWidth *
                                        (isLargeScreen
                                            ? 0.014
                                            : isTablet
                                            ? 0.025
                                            : 0.035),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
