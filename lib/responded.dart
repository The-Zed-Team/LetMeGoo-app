import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letmegoo/constants/app_theme.dart';

class Responded extends StatelessWidget {
  const Responded({super.key});

  @override
  Widget build(BuildContext context) {
    final String formattedDateTime = DateFormat(
      'HH:mm | d MMMM y',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/seen.png', height: 185, width: 185),
            const SizedBox(height: 10),
            Text("Owner Responded", style: AppFonts.semiBold24()),
            const SizedBox(height: 10),
            Text(
              "The vehicle owner has replied to your report.\nPlease review their response and confirm if the\nissue has been resolved.",
              textAlign: TextAlign.center,
              style: AppFonts.regular14(color: Color(0xFF656565)),
            ),
            const SizedBox(height: 20),
            Text(
              formattedDateTime,
              style: AppFonts.regular14(color: Color(0xFF656565)),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Details of Owner", style: AppFonts.semiBold16()),
                      Spacer(),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFD8F5FF),
                        child: Text(
                          "ER",
                          style: AppFonts.semiBold20(color: Color(0xFF31C5F4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Edwin Emmanuel Roy",
                            style: AppFonts.semiBold20(),
                          ),
                          Text(
                            "heyedvi@uxbubble.com",
                            style: AppFonts.regular14(),
                          ),
                          Text("9999999999", style: AppFonts.regular14()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add your chat navigation logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "View Chat",
                  style: AppFonts.semiBold16(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
