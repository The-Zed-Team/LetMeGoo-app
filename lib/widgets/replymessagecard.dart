import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

//Reply message
class Replymessagecard extends StatelessWidget {
  final ImageProvider? profileImage; // optional
  final String message;

  const Replymessagecard({super.key, this.profileImage, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        right: 16.0,
        top: 8,
        bottom: 8,
      ), // Right padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the right
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Profile Icon (optional)
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profileImage == null ? AppColors.darkGreen : null,
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
                          color: AppColors.background,
                          size: 20,
                        )
                        : null,
              ),

              // Message Bubble
              Container(
                constraints: const BoxConstraints(maxWidth: 275),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen, // Light green for reply
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Text(message, style: AppFonts.regular13()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
