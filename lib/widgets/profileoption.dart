// lib/widgets/profileoption.dart
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class Profileoption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const Profileoption({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.005,
      ),
      leading: Icon(
        icon,
        color: AppColors.textPrimary,
        size:
            screenWidth *
            (isLargeScreen
                ? 0.025
                : isTablet
                ? 0.035
                : 0.06),
      ),
      title: Text(
        title,
        style: AppFonts.regular16().copyWith(
          fontSize:
              screenWidth *
              (isLargeScreen
                  ? 0.016
                  : isTablet
                  ? 0.025
                  : 0.04),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
