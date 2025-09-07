import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letmegoo/constants/app_theme.dart';

class BlockClearedPage extends StatelessWidget {
  const BlockClearedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🕒 Get current date and time formatted
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('HH:mm | dd MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: Colors.white, // bright background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text('Confirmation Pending', style: AppFonts.semiBold20()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // 🔒✅ Image
            Center(
              child: Image.asset('assets/block.png', height: 114, width: 114),
            ),

            const SizedBox(height: 20),

            // 📝 Block Cleared Successfully text
            Text(
              'Block Cleared Successfully',
              textAlign: TextAlign.center,
              style: AppFonts.semiBold24(),
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              "You’ve confirmed the block is cleared. Thanks\nfor helping keep the space accessible for\neveryone.",
              textAlign: TextAlign.center,
              style: AppFonts.regular14(color: Color(0xFF656565)),
            ),

            const SizedBox(height: 30),

            // Report Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Report Status', style: AppFonts.semiBold14()),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: AppColors.darkGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Solved',
                        style: AppFonts.regular16(color: Color(0xFF0BB908)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Time Resolved (live)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time Resolved', style: AppFonts.semiBold14()),
                Text(
                  formattedDate, // ⏰ live current time and date
                  style: AppFonts.regular14(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Report ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Report ID', style: AppFonts.semiBold14()),
                Text('LMG-98471', style: AppFonts.regular14()),
              ],
            ),

            const SizedBox(height: 90),

            // Call Customer Support Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.call, color: Colors.black),
              label: Text(
                'Call Customer Support',
                style: AppFonts.semiBold14(),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.textTertiary),
              ),
            ),

            const SizedBox(height: 16),

            // Back to home button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to home',
                  style: AppFonts.semiBold16(color: Color(0xFFFFFFFF)),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
