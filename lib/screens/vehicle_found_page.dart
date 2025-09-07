import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letmegoo/constants/app_images.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/vehicle.dart';
import 'package:letmegoo/screens/create_report_page.dart';
import 'package:letmegoo/widgets/commonbutton.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleFoundPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleFoundPage({super.key, required this.vehicle});

  @override
  State<VehicleFoundPage> createState() => _VehicleFoundPageState();
}

class _VehicleFoundPageState extends State<VehicleFoundPage> {
  bool _showDetails = true;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('HH:mm | dd MMMM yyyy').format(now);

    // Get screen dimensions for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isLargeScreen = screenHeight > 800;

    // Responsive values
    final horizontalPadding = screenWidth * 0.06; // 6% of screen width
    final imageSize = isSmallScreen ? 120.0 : (isLargeScreen ? 200.0 : 185.0);
    final cardPadding = screenWidth * 0.03; // 3% of screen width
    final iconSize = isSmallScreen ? 40.0 : 50.0;
    final buttonVerticalPadding = isSmallScreen ? 12.0 : 16.0;

    // Determine if owner details should be visible based on privacy
    final bool isPublic =
        widget.vehicle.owner.privacyPreference == PrivacyPreference.public;
    final bool isPrivate =
        widget.vehicle.owner.privacyPreference == PrivacyPreference.private;
    final bool isAnonymous =
        widget.vehicle.owner.privacyPreference == PrivacyPreference.anonymous;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: isSmallScreen ? 10 : 20),

                      // Responsive image
                      Image.asset(
                        AppImages.lock,
                        height: imageSize,
                        width: imageSize,
                      ),
                      SizedBox(height: isSmallScreen ? 5 : 10),

                      // Title with responsive font
                      Text(
                        "Vehicle Found",
                        textAlign: TextAlign.center,
                        style: AppFonts.semiBold24().copyWith(
                          fontSize: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 5 : 10),

                      // Description with responsive font
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        child: Text(
                          "We found the vehicle owner in our database.\nYou can contact them directly or report\nthe vehicle for blocking.",
                          textAlign: TextAlign.center,
                          style: AppFonts.regular14(
                            color: const Color(0xFF656565),
                          ).copyWith(fontSize: isSmallScreen ? 12 : 14),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 20),

                      // Date with responsive font
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: const Color(0xFF656565),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 30),

                      // Vehicle details card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Vehicle Details",
                                style: AppFonts.semiBold16().copyWith(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 5 : 10),
                              Row(
                                children: [
                                  Container(
                                    width: iconSize,
                                    height: iconSize,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE0F7FA),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.directions_car,
                                        color: const Color(0xFF31C5F4),
                                        size: iconSize * 0.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.vehicle.vehicleNumber,
                                          style: AppFonts.semiBold20().copyWith(
                                            fontSize: isSmallScreen ? 16 : 20,
                                          ),
                                        ),
                                        Text(
                                          widget.vehicle.vehicleType,
                                          style: AppFonts.regular14().copyWith(
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                        ),
                                        if (widget.vehicle.brand != null)
                                          Text(
                                            widget.vehicle.brand!,
                                            style: AppFonts.regular14()
                                                .copyWith(
                                                  fontSize:
                                                      isSmallScreen ? 12 : 14,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 10 : 20),

                      // Owner details card with toggle (only if not anonymous)
                      if (!isAnonymous)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(cardPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title row with down/up arrow
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showDetails = !_showDetails;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Details of Owner",
                                        style: AppFonts.semiBold16().copyWith(
                                          fontSize: isSmallScreen ? 14 : 16,
                                        ),
                                      ),
                                      Icon(
                                        _showDetails
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Colors.black,
                                        size: isSmallScreen ? 20 : 24,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 5 : 10),

                                // Owner details (conditionally shown)
                                if (_showDetails)
                                  Row(
                                    children: [
                                      Container(
                                        width: iconSize,
                                        height: iconSize,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE0F7FA),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getInitials(
                                              widget.vehicle.owner.fullname,
                                            ),
                                            style: AppFonts.semiBold20(
                                              color: const Color(0xFF31C5F4),
                                            ).copyWith(
                                              fontSize: isSmallScreen ? 14 : 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isPublic
                                                  ? (widget
                                                      .vehicle
                                                      .owner
                                                      .fullname)
                                                  : _maskName(
                                                    widget
                                                        .vehicle
                                                        .owner
                                                        .fullname,
                                                  ),
                                              style: AppFonts.semiBold20()
                                                  .copyWith(
                                                    fontSize:
                                                        isSmallScreen ? 16 : 20,
                                                  ),
                                            ),
                                            if (isPublic &&
                                                widget
                                                    .vehicle
                                                    .owner
                                                    .email
                                                    .isNotEmpty)
                                              Text(
                                                widget.vehicle.owner.email,
                                                style: AppFonts.regular14()
                                                    .copyWith(
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 12
                                                              : 14,
                                                    ),
                                              ),
                                            if (isPublic &&
                                                widget
                                                    .vehicle
                                                    .owner
                                                    .phoneNumber
                                                    .isNotEmpty)
                                              Text(
                                                widget
                                                    .vehicle
                                                    .owner
                                                    .phoneNumber,
                                                style: AppFonts.regular14()
                                                    .copyWith(
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 12
                                                              : 14,
                                                    ),
                                              ),
                                            if (isPrivate) ...[
                                              Text(
                                                "Email: ****@*****.com",
                                                style: AppFonts.regular14()
                                                    .copyWith(
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 12
                                                              : 14,
                                                    ),
                                              ),
                                              Text(
                                                "Phone: ****-***-***",
                                                style: AppFonts.regular14()
                                                    .copyWith(
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 12
                                                              : 14,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: isSmallScreen ? 20 : 40),

                      // Action buttons
                      Column(
                        children: [
                          // Call button (only for public owners)
                          if (isPublic &&
                              widget.vehicle.owner.phoneNumber.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    () => _makePhoneCall(
                                      widget.vehicle.owner.phoneNumber,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    vertical: buttonVerticalPadding,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      "Call Owner",
                                      style: AppFonts.semiBold16(
                                        color: Colors.white,
                                      ).copyWith(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          if (isPublic &&
                              widget.vehicle.owner.phoneNumber.isNotEmpty)
                            SizedBox(height: isSmallScreen ? 8 : 16),

                          // Report button (always visible)
                          CommonButton(
                            text: "Inform Owner",
                            onTap: _goToReportPage,
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getInitials(String? fullname) {
    if (fullname == null || fullname.isEmpty) return "NA";

    final parts = fullname.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else {
      return fullname.substring(0, 1).toUpperCase();
    }
  }

  String _maskName(String? fullname) {
    if (fullname == null || fullname.isEmpty) return "Unknown";

    final parts = fullname.split(' ');
    if (parts.length >= 2) {
      return "${parts[0]} ${"*" * parts[1].length}";
    } else {
      return "${fullname[0]}${"*" * (fullname.length - 1)}";
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri launchUri = Uri(scheme: 'tel', path: "+$cleanNumber");

    print('Attempting to call: $cleanNumber'); // Debug log
    print('Launch URI: $launchUri'); // Debug log

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication, // Force external app
        );
      } else {
        print('Cannot launch URL: $launchUri'); // Debug log
        _showErrorSnackBar(
          'Could not launch phone dialer. Phone app may not be available.',
        );
      }
    } catch (e) {
      print('Error launching phone dialer: $e'); // Debug log
      _showErrorSnackBar('Error launching phone dialer: $e');
    }
  }

  void _goToReportPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateReportPage(
              registrationNumber: widget.vehicle.vehicleNumber,
            ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.darkRed),
    );
  }
}
