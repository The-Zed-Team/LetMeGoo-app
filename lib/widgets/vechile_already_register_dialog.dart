import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleAlreadyRegisteredDialog extends StatelessWidget {
  final String vehicleNumber;
  final VoidCallback? onContactSupport;

  const VehicleAlreadyRegisteredDialog({
    super.key,
    required this.vehicleNumber,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.darkRed,
            size: isTablet ? 48 : 40,
          ),
          SizedBox(height: 12),
          Text(
            'Vehicle Already Registered',
            style: AppFonts.bold18().copyWith(
              fontSize: isTablet ? 20 : 18,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'The vehicle number "$vehicleNumber" is already registered in our system.',
            style: AppFonts.regular14().copyWith(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppColors.primary,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Our team will help you resolve this issue',
                    style: AppFonts.regular14().copyWith(
                      fontSize: isTablet ? 15 : 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Open WhatsApp with support message
                  await _openWhatsAppSupport(vehicleNumber);

                  // Call the callback if provided
                  if (onContactSupport != null) {
                    onContactSupport!();
                  }
                },
                icon: Icon(
                  Icons.headset_mic,
                  color: Colors.white,
                  size: isTablet ? 20 : 18,
                ),
                label: Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Method to open WhatsApp with predefined message
  static Future<void> _openWhatsAppSupport(String vehicleNumber) async {
    // Create the properly formatted message
    final String message =
        "Hello, I am unable to register my vehicle number $vehicleNumber. The system shows it is already registered. Could you please help me resolve this issue?";

    // URL encode the message to handle special characters and spaces
    final String encodedMessage = Uri.encodeComponent(message);

    // Create the WhatsApp URL
    final String whatsappUrl =
        "https://api.whatsapp.com/send/?phone=918281035452&text=$encodedMessage&type=phone_number&app_absent=0";

    try {
      final Uri url = Uri.parse(whatsappUrl);

      // Check if WhatsApp can be launched
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode:
              LaunchMode
                  .externalApplication, // Opens in WhatsApp app if available
        );
      } else {
        // If WhatsApp app is not available, try opening in browser
        await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
      }
    } catch (e) {
      // Handle any errors (you might want to show a snackbar or dialog)
      print('Error opening WhatsApp: $e');
    }
  }

  static void show(
    BuildContext context, {
    required String vehicleNumber,
    VoidCallback? onContactSupport,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => VehicleAlreadyRegisteredDialog(
            vehicleNumber: vehicleNumber,
            onContactSupport: onContactSupport,
          ),
    );
  }
}
