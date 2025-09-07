import 'package:flutter/material.dart';
import 'package:letmegoo/widgets/main_app.dart';

class CoreUtil {
  static void goToHomePage(BuildContext context) {
    // More defensive approach - check the actual navigator state
    final navigator = Navigator.of(context);

    // Post frame callback to ensure the navigation happens after current build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        try {
          // Check if we can actually remove routes
          if (navigator.canPop()) {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainApp()),
              (route) => false,
            );
          } else {
            // Use pushReplacement for safer navigation
            navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => const MainApp()),
            );
          }
        } catch (e) {
          // Fallback to simple push
          navigator.push(
            MaterialPageRoute(builder: (context) => const MainApp()),
          );
        }
      }
    });
  }
}
