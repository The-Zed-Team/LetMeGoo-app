import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

//Received Message
class Messagecard extends StatelessWidget {
  final ImageProvider? profileImage; // optional
  final ImageProvider mainImage;
  final String message;

  const Messagecard({
    super.key,
    this.profileImage,
    required this.mainImage,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Icon or Fallback
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: profileImage == null ? AppColors.darkYellow : null,
              image:
                  profileImage != null
                      ? DecorationImage(image: profileImage!, fit: BoxFit.cover)
                      : null,
            ),
            child:
                profileImage == null
                    ? const Icon(
                      Icons.person,
                      color: AppColors.background,
                      size: 20,
                    )
                    : null,
          ),

          const SizedBox(height: 12),

          // Main Image
          Container(
            height: 275,
            width: 275,
            decoration: BoxDecoration(
              image: DecorationImage(image: mainImage, fit: BoxFit.cover),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),

              color: AppColors.textSecondary, // fallback background
            ),
          ),

          const SizedBox(height: 12),

          // Message (auto height)
          Container(
            width: 275,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(message, style: AppFonts.regular13()),
          ),
        ],
      ),
    );
  }
}
