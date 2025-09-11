// lib/services/notification_test_helper.dart
// Enhanced version for debugging push notification issues

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letmegoo/services/notification_service.dart';
import 'package:letmegoo/services/device_service.dart';
import 'package:letmegoo/services/analytics_service.dart';

class NotificationTestHelper {
  /// Comprehensive notification debugging
  static Future<void> debugNotificationSetup() async {
    print('🔍 === NOTIFICATION DEBUGGING START ===');

    try {
      // 1. Check Firebase Auth
      await _checkFirebaseAuth();

      // 2. Check notification permissions
      await _checkNotificationPermissions();

      // 3. Check FCM token
      await _checkFCMToken();

      // 4. Check device registration
      await _checkDeviceRegistration();

      // 5. Test notification handlers
      _testNotificationHandlers();

      print('✅ === NOTIFICATION DEBUGGING COMPLETE ===');
    } catch (e) {
      print('❌ Error during debugging: $e');
    }
  }

  static Future<void> _checkFirebaseAuth() async {
    print('\n📱 1. FIREBASE AUTH CHECK:');

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('✅ User authenticated: ${user.email}');
      print('✅ User ID: ${user.uid}');

      try {
        final token = await user.getIdToken();
        print('✅ ID Token obtained (length: ${token?.length})');
      } catch (e) {
        print('❌ Failed to get ID token: $e');
      }
    } else {
      print('❌ No authenticated user found');
    }
  }

  static Future<void> _checkNotificationPermissions() async {
    print('\n🔔 2. NOTIFICATION PERMISSIONS:');

    try {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      print('Status: ${settings.authorizationStatus}');
      print('Alert: ${settings.alert}');
      print('Sound: ${settings.sound}');
      print('Badge: ${settings.badge}');
      print('Announcement: ${settings.announcement}');
      print('CarPlay: ${settings.carPlay}');
      print('Lock Screen: ${settings.lockScreen}');
      print('Notification Center: ${settings.notificationCenter}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notifications are FULLY authorized');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Notifications are provisionally authorized');
      } else {
        print(
          '❌ Notifications are NOT authorized: ${settings.authorizationStatus}',
        );
      }
    } catch (e) {
      print('❌ Error checking permissions: $e');
    }
  }

  static Future<void> _checkFCMToken() async {
    print('\n🔑 3. FCM TOKEN CHECK:');

    try {
      final String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print('✅ FCM Token obtained');
        print('Token (first 20 chars): ${token.substring(0, 20)}...');
        print(
          'Token (last 20 chars): ...${token.substring(token.length - 20)}',
        );
        print('Full token length: ${token.length}');

        // Save to clipboard or log for testing
        print('\n📋 COPY THIS TOKEN FOR TESTING:');
        print(token);
        print(
          'Use this token in Firebase Console > Cloud Messaging > Send test message',
        );
      } else {
        print('❌ Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  static Future<void> _checkDeviceRegistration() async {
    print('\n📱 4. DEVICE REGISTRATION CHECK:');

    try {
      final deviceData = await DeviceService.checkDeviceRegistration();

      if (deviceData != null) {
        print('✅ Device is registered on server');
        print('Device ID: ${deviceData['id']}');
        print('Platform: ${deviceData['platform']}');
        print('Push enabled: ${deviceData['push_enabled']}');
        print('Status: ${deviceData['status']}');
        print('Last seen: ${deviceData['last_seen']}');
      } else {
        print('❌ Device NOT registered on server');
        print('Attempting to register...');

        final registrationResult = await DeviceService.registerDevice();
        if (registrationResult != null) {
          print('✅ Device registered successfully');
        } else {
          print('❌ Device registration failed');
        }
      }
    } catch (e) {
      print('❌ Error checking device registration: $e');
    }
  }

  static void _testNotificationHandlers() {
    print('\n🎯 5. NOTIFICATION HANDLERS TEST:');

    print('Setting up test listeners...');

    // Test foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🟢 TEST: Foreground message received!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    // Test background message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🟡 TEST: Background message opened app!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    print('✅ Test listeners configured');
  }

  /// Send test notification via server (if you have an endpoint)
  static Future<void> sendTestNotification() async {
    print('\n🧪 SENDING TEST NOTIFICATION:');

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user');
        return;
      }

      final String? idToken = await user.getIdToken();
      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (idToken == null || fcmToken == null) {
        print('❌ Missing required tokens');
        return;
      }

      // You would implement this endpoint on your server
      print('📤 Would send test notification to: $fcmToken');
      print('With auth token: ${idToken.substring(0, 20)}...');

      // Log the test attempt
      await AnalyticsService.logEvent(
        'test_notification_requested',
        parameters: {'platform': 'ios', 'user_id': user.uid},
      );
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  /// Test notification navigation
  static void testNotificationNavigation() {
    print('\n🧭 TESTING NOTIFICATION NAVIGATION:');

    try {
      NotificationService.navigateToHomePage();
      print('✅ Navigation test completed');
    } catch (e) {
      print('❌ Navigation test failed: $e');
    }
  }

  /// Request notification permissions again
  static Future<void> requestPermissionsAgain() async {
    print('\n🔄 RE-REQUESTING PERMISSIONS:');

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('New permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('⚠️ Permissions denied. User must enable in Settings app.');
        print('📱 Go to: Settings > [Your App] > Notifications');
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Check if app can receive background notifications
  static Future<void> checkBackgroundCapability() async {
    print('\n📋 BACKGROUND CAPABILITY CHECK:');

    // Check initial message (app opened from terminated state)
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('✅ App was opened from a notification');
      print('Title: ${initialMessage.notification?.title}');
    } else {
      print('ℹ️ App was not opened from a notification');
    }
  }
}

// Usage: Add this to any screen for debugging
/*
// In your widget's build method:
Column(
  children: [
    ElevatedButton(
      onPressed: NotificationTestHelper.debugNotificationSetup,
      child: Text('Debug Notification Setup'),
    ),
    ElevatedButton(
      onPressed: NotificationTestHelper.sendTestNotification,
      child: Text('Send Test Notification'),
    ),
    ElevatedButton(
      onPressed: NotificationTestHelper.testNotificationNavigation,
      child: Text('Test Navigation'),
    ),
    ElevatedButton(
      onPressed: NotificationTestHelper.requestPermissionsAgain,
      child: Text('Request Permissions Again'),
    ),
  ],
)
*/
