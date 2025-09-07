  
  import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

  
  Widget buildDivider(double screenWidth) {
    return Center(
      child: Container(
        width: screenWidth * 0.85,
        height: 1,
        color: AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }