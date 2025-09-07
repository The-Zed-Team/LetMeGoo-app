import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letmegoo/services/analytics_service.dart'; // 🔥 ADD THIS IMPORT

class DeviceService {
  static const String baseUrl = 'https://api.letmegoo.com/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  /// Register device for push notifications
  static Future<Map<String, dynamic>?> registerDevice() async {
    try {
      // Get Firebase user and token
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('No Firebase user found');
      }

      final String? idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }

      // Get device information
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();
      final fcmToken = await _getFCMToken();
      final pushStatus = await _getPushNotificationStatus();

      final requestBody = {
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'device_model': deviceInfo['model'] ?? 'Unknown',
        'os_version': deviceInfo['version'] ?? 'Unknown',
        'app_version': packageInfo.version,
        'language_code': _getLanguageCode(),
        'push_enabled': pushStatus,
        'device_token': fcmToken ?? '',
      };

      print('Device registration payload: $requestBody');

      final response = await http
          .post(
            Uri.parse('$baseUrl/device/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: json.encode(requestBody),
          )
          .timeout(timeoutDuration);

      print('Device registration response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔥 ADD THIS - Track successful device registration
        await AnalyticsService.logEvent(
          'device_registered',
          parameters: {
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'push_enabled': pushStatus,
            'status_code': response.statusCode,
          },
        );

        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // 🔥 ADD THIS - Track failed device registration
        await AnalyticsService.logEvent(
          'device_registration_failed',
          parameters: {
            'status_code': response.statusCode,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );

        throw Exception(
          'Device registration failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Device registration error: $e');
      // 🔥 ADD THIS - Track device registration errors
      AnalyticsService.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Get device information based on platform
  static Future<Map<String, String>> _getDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return {
          'model': androidInfo.model,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return {'model': iosInfo.model, 'version': iosInfo.systemVersion};
      }
    } catch (e) {
      print('Error getting device info: $e');
      // 🔥 ADD THIS - Track device info errors
      AnalyticsService.recordError(e, StackTrace.current);
    }

    return {'model': 'Unknown', 'version': 'Unknown'};
  }

  /// Get FCM token for push notifications
  static Future<String?> _getFCMToken() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission first
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      print('FCM Token: $token');

      // 🔥 ADD THIS - Track FCM token retrieval
      await AnalyticsService.logEvent(
        'fcm_token_retrieved',
        parameters: {
          'success': token != null,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      // 🔥 ADD THIS - Track FCM token errors
      AnalyticsService.recordError(e, StackTrace.current);
      return null;
    }
  }

  /// Check push notification permission status
  static Future<String> _getPushNotificationStatus() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();

      String status;
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          status = 'ENABLED';
          break;
        case AuthorizationStatus.denied:
          status = 'DISABLED';
          break;
        default:
          status = 'UNKNOWN';
      }

      // 🔥 ADD THIS - Track push notification permission status
      await AnalyticsService.logEvent(
        'push_permission_check',
        parameters: {
          'status': status,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );

      return status;
    } catch (e) {
      print('Error checking push notification status: $e');
      // 🔥 ADD THIS - Track permission check errors
      AnalyticsService.recordError(e, StackTrace.current);
      return 'UNKNOWN';
    }
  }

  /// Get language code from locale
  static String _getLanguageCode() {
    try {
      final locale = Platform.localeName;
      return locale.split('_')[0].toLowerCase();
    } catch (e) {
      return 'en'; // Default to English
    }
  }

  /// Update device token when FCM token refreshes
  static Future<void> updateDeviceToken(String newToken) async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      final String? idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) return;

      final response = await http
          .patch(
            Uri.parse('$baseUrl/device/update-token'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: json.encode({'device_token': newToken}),
          )
          .timeout(timeoutDuration);

      print('Device token update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 🔥 ADD THIS - Track successful token update
        await AnalyticsService.logEvent(
          'device_token_updated',
          parameters: {
            'success': true,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );
      } else {
        // 🔥 ADD THIS - Track failed token update
        await AnalyticsService.logEvent(
          'device_token_update_failed',
          parameters: {
            'status_code': response.statusCode,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );
      }
    } catch (e) {
      print('Error updating device token: $e');
      // 🔥 ADD THIS - Track token update errors
      AnalyticsService.recordError(e, StackTrace.current);
    }
  }

  /// Unregister device (call on logout)
  static Future<void> unregisterDevice() async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      final String? idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) return;

      final response = await http
          .delete(
            Uri.parse('$baseUrl/device/unregister'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          )
          .timeout(timeoutDuration);

      print('Device unregister response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 🔥 ADD THIS - Track successful device unregistration
        await AnalyticsService.logEvent(
          'device_unregistered',
          parameters: {
            'success': true,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );
      } else {
        // 🔥 ADD THIS - Track failed device unregistration
        await AnalyticsService.logEvent(
          'device_unregister_failed',
          parameters: {
            'status_code': response.statusCode,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );
      }
    } catch (e) {
      print('Error unregistering device: $e');
      // 🔥 ADD THIS - Track unregistration errors
      AnalyticsService.recordError(e, StackTrace.current);
    }
  }

  // Add this method to your existing DeviceService class
  static Future<Map<String, dynamic>?> checkDeviceRegistration() async {
    try {
      // Get Firebase user and token
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('No Firebase user found');
      }

      final String? idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }

      // Get FCM token to use as device identifier
      final fcmToken = await _getFCMToken();
      if (fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }

      print('Checking device registration with token: $fcmToken');

      final response = await http
          .get(
            Uri.parse('$baseUrl/device/get/$fcmToken'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          )
          .timeout(timeoutDuration);

      print('Device check response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Device is registered
        // 🔥 ADD THIS - Track device found
        await AnalyticsService.logEvent(
          'device_check_found',
          parameters: {'platform': Platform.isAndroid ? 'android' : 'ios'},
        );

        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        // Device not found/not registered
        // 🔥 ADD THIS - Track device not found (this was the 404 error you saw)
        await AnalyticsService.logEvent(
          'device_check_not_found',
          parameters: {
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'status_code': 404,
          },
        );

        return null;
      } else {
        // 🔥 ADD THIS - Track other check failures
        await AnalyticsService.logEvent(
          'device_check_failed',
          parameters: {
            'status_code': response.statusCode,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );

        throw Exception(
          'Device check failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Device check error: $e');
      // 🔥 ADD THIS - Track device check errors
      AnalyticsService.recordError(e, StackTrace.current);
      // Return null if check fails - we'll treat it as not registered
      return null;
    }
  }

  /// Check if device is registered and register if not
  static Future<bool> ensureDeviceRegistered() async {
    try {
      // 🔥 ADD THIS - Track device registration flow start
      await AnalyticsService.logEvent(
        'device_registration_flow_started',
        parameters: {'platform': Platform.isAndroid ? 'android' : 'ios'},
      );

      // First check if device is already registered
      final deviceData = await checkDeviceRegistration();

      if (deviceData != null) {
        print('Device already registered: ${deviceData['id']}');

        // 🔥 ADD THIS - Track device already registered
        await AnalyticsService.logEvent(
          'device_already_registered',
          parameters: {
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'has_device_id': deviceData['id'] != null,
          },
        );

        return true;
      }

      print('Device not registered, registering now...');

      // Device not registered, register it
      final registrationResult = await registerDevice();

      if (registrationResult != null) {
        print(
          'Device registered successfully: ${registrationResult['id'] ?? 'unknown'}',
        );

        // 🔥 ADD THIS - Track successful new registration
        await AnalyticsService.logEvent(
          'device_newly_registered',
          parameters: {
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'device_id':
                (registrationResult['id'] as Object?)?.toString() ?? 'unknown',
          },
        );

        return true;
      }

      // 🔥 ADD THIS - Track registration failure
      await AnalyticsService.logEvent(
        'device_registration_flow_failed',
        parameters: {
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'reason': 'registration_returned_null',
        },
      );

      return false;
    } catch (e) {
      print('Error ensuring device registration: $e');
      // 🔥 ADD THIS - Track overall registration flow errors
      AnalyticsService.recordError(e, StackTrace.current);

      await AnalyticsService.logEvent(
        'device_registration_flow_error',
        parameters: {
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'error_type': e.runtimeType.toString(),
        },
      );

      return false;
    }
  }
}
