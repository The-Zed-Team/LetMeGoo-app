import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

/// Modal dialog for selecting image source
///
/// Displays a bottom sheet with options to:
/// - Take a photo with camera
/// - Choose from gallery (single)
/// - Select multiple photos
class ImagePickerDialog extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallerySingle;
  final VoidCallback onGalleryMultiple;

  const ImagePickerDialog({
    super.key,
    required this.onCamera,
    required this.onGallerySingle,
    required this.onGalleryMultiple,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag handle
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Photos to Report',
                      style: TextStyle(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.018
                                : isTablet
                                ? 0.028
                                : 0.045),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Photos help provide clear evidence for your report',
                      style: TextStyle(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.014
                                : isTablet
                                ? 0.022
                                : 0.032),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Camera option
                    ImageSourceOption(
                      icon: Icons.camera_alt,
                      title: 'Take Photo',
                      description: 'Use camera to capture evidence',
                      onTap: () {
                        Navigator.pop(context);
                        onCamera();
                      },
                      screenWidth: screenWidth,
                      isTablet: isTablet,
                      isLargeScreen: isLargeScreen,
                    ),
                    SizedBox(height: screenHeight * 0.012),

                    // Gallery single option
                    ImageSourceOption(
                      icon: Icons.photo_library,
                      title: 'Choose from Gallery',
                      description: 'Select existing photos',
                      onTap: () {
                        Navigator.pop(context);
                        onGallerySingle();
                      },
                      screenWidth: screenWidth,
                      isTablet: isTablet,
                      isLargeScreen: isLargeScreen,
                    ),
                    SizedBox(height: screenHeight * 0.012),

                    // Gallery multiple option
                    ImageSourceOption(
                      icon: Icons.photo_library_outlined,
                      title: 'Select Multiple Photos',
                      description: 'Choose several photos at once',
                      onTap: () {
                        Navigator.pop(context);
                        onGalleryMultiple();
                      },
                      screenWidth: screenWidth,
                      isTablet: isTablet,
                      isLargeScreen: isLargeScreen,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize:
                              screenWidth *
                              (isLargeScreen
                                  ? 0.016
                                  : isTablet
                                  ? 0.025
                                  : 0.035),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the image picker dialog
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallerySingle,
    required VoidCallback onGalleryMultiple,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ImagePickerDialog(
            onCamera: onCamera,
            onGallerySingle: onGallerySingle,
            onGalleryMultiple: onGalleryMultiple,
          ),
    );
  }
}

/// Individual image source option widget
class ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final double screenWidth;
  final bool isTablet;
  final bool isLargeScreen;

  const ImageSourceOption({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.screenWidth,
    required this.isTablet,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.035),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
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
            SizedBox(width: screenWidth * 0.03),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          screenWidth *
                          (isLargeScreen
                              ? 0.014
                              : isTablet
                              ? 0.022
                              : 0.035),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize:
                          screenWidth *
                          (isLargeScreen
                              ? 0.012
                              : isTablet
                              ? 0.018
                              : 0.028),
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size:
                  screenWidth *
                  (isLargeScreen
                      ? 0.012
                      : isTablet
                      ? 0.018
                      : 0.03),
            ),
          ],
        ),
      ),
    );
  }
}
