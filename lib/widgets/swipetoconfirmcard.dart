import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:letmegoo/constants/app_images.dart';
import 'package:letmegoo/constants/app_theme.dart';

class SwipeToConfirmCard extends StatelessWidget {
  final VoidCallback onSwipe;

  const SwipeToConfirmCard({super.key, required this.onSwipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textSecondary),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(AppImages.unlock, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 100,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "All Clear?",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Swipe and let this problem disappear",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Swipe right to let the reporter know it's been taken care of",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: SwipeButton.expand(
                height: 60,
                activeThumbColor: AppColors.background,
                activeTrackColor: AppColors.primary,
                thumb: const Icon(
                  Icons.double_arrow_outlined,
                  color: Colors.black,
                ),
                onSwipe: onSwipe,
                child: Text(
                  "Swipe Right to inform the Reporter",
                  style: AppFonts.regular13(color: AppColors.background),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
