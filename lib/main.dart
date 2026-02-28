import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/core/services/notification_service.dart';
import 'package:letmegoo/features/auth/presentation/screens/login_page.dart';
import 'package:letmegoo/features/auth/presentation/screens/splash_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // CHANGED: Added !kIsWeb to ensure Crashlytics only runs on mobile
    if (!kDebugMode && !kIsWeb) {
      // Only enable Crashlytics in release mode on mobile
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Initialize notifications in background - don't await
    NotificationService.initialize().catchError((e) {
      // Log to Crashlytics if not on web
      if (!kDebugMode && !kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, null);
      }
    });
  } catch (e) {
    // Log to Crashlytics if not on web
    if (!kDebugMode && !kIsWeb) {
      FirebaseCrashlytics.instance.recordError(e, null);
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Create a global navigator key for notification navigation
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Set the navigator key in NotificationService
    NotificationService.setNavigatorKey(navigatorKey);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}
