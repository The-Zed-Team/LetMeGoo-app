// lib/widgets/usertile.dart
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class Usertile extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final String phone;
  final String? image;

  const Usertile({
    super.key,
    required this.initials,
    required this.name,
    required this.email,
    required this.phone,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius:
                screenWidth *
                (isLargeScreen
                    ? 0.04
                    : isTablet
                    ? 0.05
                    : 0.08),
            backgroundColor: AppColors.primary,
            backgroundImage: image != null ? AssetImage(image!) : null,
            child:
                image == null
                    ? Text(
                      initials,
                      style: AppFonts.semiBold18().copyWith(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.02
                                : isTablet
                                ? 0.03
                                : 0.045),
                        color: AppColors.white,
                      ),
                    )
                    : null,
          ),

          SizedBox(width: screenWidth * 0.04),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFonts.semiBold18().copyWith(
                    fontSize:
                        screenWidth *
                        (isLargeScreen
                            ? 0.02
                            : isTablet
                            ? 0.03
                            : 0.045),
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  email,
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
                ),
                Text(
                  "+$phone",
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
