/// API endpoint constants
///
/// Centralizes all API endpoint paths to avoid magic strings
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // ==================== Auth Endpoints ====================
  static const String authenticate = '/user/authenticate';
  static const String updateUserProfile = '/user/update';
  static const String updateUserStatus = '/user/status';
  static const String deleteUser = '/user/delete';
  static const String updatePrivacyPreference = '/user/privacy-preference';

  // ==================== Vehicle Endpoints ====================
  static const String vehicleCreate = '/vehicle/create';
  static const String vehicleList = '/vehicle/list';
  static const String vehicleUpdate = '/vehicle/update'; // + /{id}
  static const String vehicleDelete = '/vehicle/delete'; // + /{id}
  static const String vehicleGet = '/vehicle/get'; // + /{id}
  static const String vehicleSearch = '/vehicle/search';
  static const String vehicleTypes = '/vehicle/types';

  // ==================== Report Endpoints ====================
  static const String reportCreate = '/report/create';
  static const String reportList = '/report/list';
  static const String reportGet = '/report/get'; // + /{id}

  // ==================== Shop Endpoints ====================
  static const String shopsList = '/shops/list';
  static const String shopsWithDistance = '/shops/with-distance';

  // ==================== CTA Events Endpoints ====================
  static const String ctaEventTrack = '/cta-events/track';

  // ==================== Helper Methods ====================

  /// Gets vehicle update endpoint with ID
  static String vehicleUpdateById(String id) => '$vehicleUpdate/$id';

  /// Gets vehicle delete endpoint with ID
  static String vehicleDeleteById(String id) => '$vehicleDelete/$id';

  /// Gets vehicle get endpoint with ID
  static String vehicleGetById(String id) => '$vehicleGet/$id';

  /// Gets report get endpoint with ID
  static String reportGetById(String id) => '$reportGet/$id';
}
