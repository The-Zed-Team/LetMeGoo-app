import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

//Sender information card
class Compactreportcard extends StatelessWidget {
  final ImageProvider? profileImage;
  final String title;
  final String timestamp;
  final String location;
  final String status;

  const Compactreportcard({
    super.key,
    required this.title,
    required this.timestamp,
    required this.location,
    required this.status,
    this.profileImage,
  });

  bool get isActive => status.toLowerCase() == 'active';

  Color get statusColor => isActive ? AppColors.darkRed : AppColors.darkGreen;
  Color get statusBackground =>
      isActive ? AppColors.lightRed : AppColors.lightGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 12),
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: Center(
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkYellow,
                  image:
                      profileImage != null
                          ? DecorationImage(
                            image: profileImage!,
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    profileImage == null
                        ? const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.background,
                        )
                        : null,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Text Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.bold16()),
                const SizedBox(height: 4),
                Text(timestamp, style: AppFonts.regular13()),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: AppFonts.regular13(color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(status, style: AppFonts.bold14(color: statusColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
