// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool isLoading;
  final bool isEnabled;

  const CommonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: Container(
        width: screenWidth * 0.85, // 85% of screen width
        height: screenHeight * 0.07, // 7% of screen height
        decoration: BoxDecoration(
          color:
              isEnabled
                  ? (backgroundColor ?? AppColors.primary)
                  : AppColors.textSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child:
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? AppColors.white,
                      ),
                    ),
                  )
                  : Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? screenWidth * 0.04,
                      color: textColor ?? AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),
    );
  }
}
