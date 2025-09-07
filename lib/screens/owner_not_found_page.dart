import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_images.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/widgets/commonButton.dart';
import 'package:letmegoo/widgets/main_app.dart';

class OwnerNotFoundPage extends StatelessWidget {
  const OwnerNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
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
                          "Oh Sorry!! This vehicle is not added to our\nlist by its owner! 😔",
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
                      MaterialPageRoute(
                        builder: (context) => MainApp(),
                      ), // Replace with your home page widget
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
