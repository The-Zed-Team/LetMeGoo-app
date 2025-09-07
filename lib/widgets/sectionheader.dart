import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.02),
      child: Text(
        title,
        style: AppFonts.semiBold18().copyWith(
          fontSize:
              screenWidth *
              (isLargeScreen
                  ? 0.016
                  : isTablet
                  ? 0.025
                  : 0.038),
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
