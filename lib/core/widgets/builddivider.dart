  import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

  
  Widget buildDivider(double screenWidth) {
    return Center(
      child: Container(
        width: screenWidth * 0.85,
        height: 1,
        color: AppColors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }