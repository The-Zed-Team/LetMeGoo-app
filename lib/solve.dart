import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:letmegoo/constants/app_theme.dart';

class Solve extends StatefulWidget {
  const Solve({super.key});

  @override
  State<Solve> createState() => _OwnerSolvedPageState();
}

class _OwnerSolvedPageState extends State<Solve> {
  bool isApproved = false;

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'HH:mm | d MMMM y',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/solve.png', height: 185, width: 185),
            const SizedBox(height: 10),
            Text("Owner Solved", style: AppFonts.semiBold24()),
            const SizedBox(height: 10),
            Text(
              "The vehicle owner says the issue has been cleared.\nPlease take a moment to check and confirm if\neverything's okay.",
              textAlign: TextAlign.center,
              style: AppFonts.regular14(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 30),

            // Report Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Report Status", style: AppFonts.semiBold14()),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isApproved
                            ? AppColors.lightGreen
                            : AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color:
                            isApproved
                                ? AppColors.darkGreen
                                : AppColors.darkYellow,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isApproved ? "Approved" : "Waiting for Approval",
                        style: AppFonts.semiBold13(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Resolved
            Row(
              children: [
                Text("Time Resolved", style: AppFonts.semiBold14()),
                const Spacer(),
                Text(formattedDate, style: AppFonts.semiBold14()),
              ],
            ),
            const SizedBox(height: 16),

            // Report ID
            Row(
              children: [
                Text("Report ID", style: AppFonts.semiBold14()),
                const Spacer(),
                Text("LMG-98471", style: AppFonts.semiBold14()),
              ],
            ),
            const SizedBox(height: 100),

            Text(
              "Swipe right to approve that the block was removed",
              style: AppFonts.regular14(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Swipe Button
            SwipeButton.expand(
              activeThumbColor: Colors.transparent,
              activeTrackColor:
                  isApproved ? AppColors.primary : AppColors.primary,
              thumb: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.double_arrow_rounded,
                  color: isApproved ? AppColors.primary : AppColors.primary,
                ),
              ),
              child: Text(
                isApproved ? "Approved" : "Swipe right To approve",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onSwipe: () {
                setState(() {
                  isApproved = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Block Cleared Approved"),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
