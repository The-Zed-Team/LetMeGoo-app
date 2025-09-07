import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
// Adjust the import as needed

class CustomDivider extends StatelessWidget {
  final double screenWidth;

  const CustomDivider({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      height: 1,
      color: AppColors.textSecondary.withOpacity(0.1),
    );
  }
}
