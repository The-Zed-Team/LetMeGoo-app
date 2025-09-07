import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letmegoo/constants/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      home: ConfirmationPendingPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ConfirmationPendingPage extends StatelessWidget {
  const ConfirmationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 Define colours for each text section here
    // 🕒 Get current date and time formatted
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('HH:mm | dd MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: AppColors.background, // brighter background
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text('Confirmation Pending', style: AppFonts.semiBold20()),

        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // 🖼️ Image instead of emoji
            Center(
              child: Image.asset('assets/lock.png', height: 144, width: 144),
            ),

            // 📝 Waiting for Confirmation text
            Text('Waiting for Confirmation', style: AppFonts.semiBold24()),

            const SizedBox(height: 10),

            // Description
            Text(
              "You've marked the problem as resolved.\nWe're now waiting for the reporter to verify.",
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
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.circle, size: 10, color: AppColors.darkYellow),
                      SizedBox(width: 6),
                      Text(
                        'Verification Pending',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color:
                              AppColors.darkYellow, // 🌟 added font colour here
                        ),
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

            const SizedBox(height: 30),

            // Bottom note
            Text(
              "If you're confident the issue is resolved, no need to wait here. If the reporter responds or there's any update, we'll notify you right away.",
              style: AppFonts.regular14(color: Color(0xFF656565)),
            ),

            const SizedBox(height: 120),

            // Call Customer Support Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call, color: Colors.black),
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
                side: const BorderSide(color: Colors.black),
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
