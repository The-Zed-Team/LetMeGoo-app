class AppConstants {
  // API constants
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // App information
  static const String appName = 'Let Me Goo';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxRetries = 3;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 50;

  // Animation durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 400;
  static const int longAnimationDuration = 600;

  // Image placeholders
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String logoImage = 'assets/images/logo.png';

  // Error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String noInternetMessage =
      'No internet connection. Please check your connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';

  // Success messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String logoutSuccessMessage = 'Logout successful!';
  static const String dataUpdatedMessage = 'Data updated successfully!';
}
