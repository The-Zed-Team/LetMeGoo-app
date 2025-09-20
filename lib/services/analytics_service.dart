import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Analytics Methods
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!kDebugMode) {
      await _analytics.logEvent(name: name, parameters: parameters);
    }
    if (kDebugMode) {
      print('Analytics Event: $name with params: $parameters');
    }
  }

  static Future<void> setUserId(String userId) async {
    if (!kDebugMode) {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
    }
  }

  static Future<void> setUserProperty(String name, String value) async {
    if (!kDebugMode) {
      await _analytics.setUserProperty(name: name, value: value);
    }
  }

  // Common Events
  static Future<void> logLogin(String method) async {
    await logEvent('login', parameters: {'method': method});
  }

  static Future<void> logSignUp(String method) async {
    await logEvent('sign_up', parameters: {'method': method});
  }

  static Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  static Future<void> logButtonClick(
    String buttonName,
    String screenName,
  ) async {
    await logEvent(
      'button_click',
      parameters: {'button_name': buttonName, 'screen_name': screenName},
    );
  }

  // Location sharing specific events
  static Future<void> logLocationShared(String recipientType) async {
    await logEvent(
      'location_shared',
      parameters: {'recipient_type': recipientType},
    );
  }

  // Notification events
  static Future<void> logNotificationSent(String notificationType) async {
    await logEvent('notification_sent', parameters: {'type': notificationType});
  }

  // Feature usage
  static Future<void> logFeatureUsed(String featureName) async {
    await logEvent('feature_used', parameters: {'feature': featureName});
  }

  // Emergency features
  static Future<void> logEmergencyActivated(String emergencyType) async {
    await logEvent('emergency_activated', parameters: {'type': emergencyType});
  }

  // Crashlytics Methods
  static void recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) {
    if (!kDebugMode) {
      _crashlytics.recordError(exception, stackTrace, fatal: fatal);
    } else {
      print('Error recorded: $exception');
    }
  }

  static void log(String message) {
    if (!kDebugMode) {
      _crashlytics.log(message);
    } else {
      print('Crashlytics log: $message');
    }
  }

  static Future<void> setCrashlyticsUserId(String userId) async {
    if (!kDebugMode) {
      await _crashlytics.setUserIdentifier(userId);
    }
  }

  static Future<void> setCustomKey(String key, Object value) async {
    if (!kDebugMode) {
      await _crashlytics.setCustomKey(key, value);
    }
  }
}
