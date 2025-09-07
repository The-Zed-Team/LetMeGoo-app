import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

//bottombarcards

class Customstatustag extends StatelessWidget {
  final String message;
  final Color borderColor;
  final Color backgroundColor;

  const Customstatustag({
    super.key,
    required this.message,
    this.borderColor = AppColors.darkRed,
    this.backgroundColor = AppColors.lightRed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        color: backgroundColor,
      ),
      child: Center(child: Text(message, style: AppFonts.bold13())),
    );
  }
}
