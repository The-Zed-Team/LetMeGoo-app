// lib/widgets/parking_location_card.dart
import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingLocationCard extends StatelessWidget {
  final String id;
  final String vehicleNumber;
  final String notes;
  final String timeDate;
  final String location;
  final String visibility;
  final bool hasImage;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String user;
  final String? userImage;
  final VoidCallback? onDelete;
  final VoidCallback? onViewLocation;

  const ParkingLocationCard({
    super.key,
    required this.id,
    required this.vehicleNumber,
    required this.notes,
    required this.timeDate,
    required this.location,
    required this.visibility,
    required this.hasImage,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.user,
    this.userImage,
    this.onDelete,
    this.onViewLocation,
  });

  /// Open map with coordinates
  Future<void> _openMap(BuildContext context) async {
    try {
      // Create map URLs for different platforms
      final String googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final String appleMapsUrl =
          'https://maps.apple.com/?q=$latitude,$longitude';
      final String universalUrl = 'geo:$latitude,$longitude';

      // Try to launch in order of preference
      List<String> urls = [
        googleMapsUrl, // Works on both Android and iOS
        appleMapsUrl, // iOS fallback
        universalUrl, // Android fallback
      ];

      bool launched = false;

      for (String url in urls) {
        final Uri uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Open in external maps app
          );

          if (launched) {
            print('Successfully opened map with: $url');
            break;
          }
        }
      }

      if (!launched) {
        _showSnackBar(context, 'No maps application available', isError: true);
      }
    } catch (e) {
      print('Error opening map: $e');
      _showSnackBar(
        context,
        'Error opening map: Invalid coordinates',
        isError: true,
      );
    }
  }

  /// Show snackbar message
  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show action menu
  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: const Text('View on Map'),
                  onTap: () {
                    Navigator.pop(context);
                    _openMap(context);
                  },
                ),
                if (onDelete != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete?.call();
                    },
                  ),
              ],
            ),
          ),
    );
  }

  /// Show full screen image dialog
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600 && screenWidth < 1024;
    final isLargeScreen = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.015,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and Vehicle Number Row with Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  timeDate,
                  style: TextStyle(
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.012
                            : isTablet
                            ? 0.02
                            : 0.032),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  // Vehicle Number Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      vehicleNumber,
                      style: TextStyle(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.012
                                : isTablet
                                ? 0.02
                                : 0.032),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Visibility Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color:
                          visibility == 'public'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          visibility == 'public' ? Icons.public : Icons.lock,
                          size: screenWidth * 0.03,
                          color:
                              visibility == 'public'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          visibility.toUpperCase(),
                          style: TextStyle(
                            fontSize:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.01
                                    : isTablet
                                    ? 0.017
                                    : 0.025),
                            color:
                                visibility == 'public'
                                    ? Colors.green
                                    : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions Menu Button
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showActionMenu(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.025),

          // Location Row with tap functionality
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.025),
            child: GestureDetector(
              onTap: () => _openMap(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                  color: AppColors.primary.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: screenWidth * 0.04,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
                      child: Text(
                        "View parking location on map",
                        style: TextStyle(
                          fontSize:
                              screenWidth *
                              (isLargeScreen
                                  ? 0.014
                                  : isTablet
                                  ? 0.022
                                  : 0.035),
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.open_in_new,
                      size: screenWidth * 0.035,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Notes Section
          if (notes.isNotEmpty && notes != 'No notes provided')
            Text(
              notes,
              style: TextStyle(
                fontSize:
                    screenWidth *
                    (isLargeScreen
                        ? 0.016
                        : isTablet
                        ? 0.025
                        : 0.04),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

          if (notes.isNotEmpty && notes != 'No notes provided')
            SizedBox(height: screenWidth * 0.025),

          // Image Section - With tap to view full image
          if (hasImage && imageUrl != null) ...[
            GestureDetector(
              onTap: () => _showFullImage(context, imageUrl!),
              child: Container(
                height: screenHeight * 0.2,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: screenWidth * 0.08,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.025),
          ],

          // User Row
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.04,
                backgroundColor: AppColors.textSecondary.withOpacity(0.3),
                backgroundImage:
                    userImage != null ? NetworkImage(userImage!) : null,
                child:
                    userImage == null
                        ? Icon(
                          Icons.person,
                          size: screenWidth * 0.04,
                          color: AppColors.textSecondary,
                        )
                        : null,
              ),
              SizedBox(width: screenWidth * 0.025),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Saved by $user",
                      style: TextStyle(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.012
                                : isTablet
                                ? 0.02
                                : 0.032),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.01
                                : isTablet
                                ? 0.017
                                : 0.028),
                        color: AppColors.textSecondary.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
