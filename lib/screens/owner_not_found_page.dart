import 'package:flutter/material.dart';
import 'package:letmegoo/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:letmegoo/constants/app_images.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/widgets/commonButton.dart';
import 'package:letmegoo/widgets/main_app.dart';

class OwnerNotFoundPage extends StatelessWidget {
  const OwnerNotFoundPage({super.key});

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 360;

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: isSmallScreen ? 48 : 56,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              // Warning title
              Text(
                "Please confirm",
                style:
                    isSmallScreen
                        ? AppFonts.semiBold18()
                        : AppFonts.semiBold20(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),

              // Warning message
              Text(
                "This option is intended for genuine emergencies only. Misuse of emergency services is a punishable offense.",
                style:
                    isSmallScreen
                        ? AppFonts.regular13(color: const Color(0xFF656565))
                        : AppFonts.regular14(color: const Color(0xFF656565)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style:
                            isSmallScreen
                                ? AppFonts.regular13(color: Colors.black87)
                                : AppFonts.regular16(color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),

                  // Proceed button
                  // Proceed button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // Fire-and-forget analytics (do not block the call)
                        AuthService.trackCtaEvent(
                          eventType: 'Button clicked',
                          eventContext: '112 clicked',
                          //relatedEntityId: '112',
                          relatedEntityType: 'emergency',
                          eventMetadata: {'source': 'OwnerNotFoundPage'},
                        );
                        final Uri phoneUri = Uri(scheme: 'tel', path: '112');
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Proceed",
                        style:
                            isSmallScreen
                                ? AppFonts.regular14(color: Colors.white)
                                : AppFonts.regular16(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        //leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
          child: Column(
            children: [
              // Main content - centered and takes available space
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Responsive image sizing
                      Image.asset(
                        AppImages.vehicle_not_found,
                        height: isSmallScreen ? 150 : 185,
                        width: isSmallScreen ? 150 : 185,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Title with responsive font sizing
                      Text(
                        "Owner Not Found",
                        style:
                            isSmallScreen
                                ? AppFonts.semiBold20()
                                : AppFonts.semiBold24(),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Description with responsive spacing
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 16,
                        ),
                        child: Text(
                          "Sorry, the vehicle is not registered\nwith LetMeGoo. 😔",
                          textAlign: TextAlign.center,
                          style:
                              isSmallScreen
                                  ? AppFonts.regular13(
                                    color: const Color(0xFF656565),
                                  )
                                  : AppFonts.regular14(
                                    color: const Color(0xFF656565),
                                  ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 24),

                      // Divider
                      Container(
                        width: isSmallScreen ? 200 : 250,
                        height: 1,
                        color: const Color(0xFFE0E0E0),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 24),

                      // Emergency info text
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 16,
                        ),
                        child: Text(
                          "Instead, you can inform Kerala Police\nEmergency for support.",
                          textAlign: TextAlign.center,
                          style:
                              isSmallScreen
                                  ? AppFonts.regular13(
                                    color: const Color(0xFF656565),
                                  )
                                  : AppFonts.regular14(
                                    color: const Color(0xFF656565),
                                  ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 24),

                      // Emergency call button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 20 : 32,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showEmergencyDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 16 : 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: isSmallScreen ? 22 : 24,
                                ),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                Text(
                                  "Call 112",
                                  style:
                                      isSmallScreen
                                          ? AppFonts.semiBold16(
                                            color: Colors.white,
                                          )
                                          : AppFonts.semiBold18(
                                            color: Colors.white,
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Button at bottom with responsive padding
              Padding(
                padding: EdgeInsets.only(
                  bottom: isSmallScreen ? 16 : 24,
                  top: 16,
                ),
                child: CommonButton(
                  text: "OK",
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => MainApp()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
