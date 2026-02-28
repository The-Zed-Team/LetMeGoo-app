/// Input validation utilities
///
/// Provides common validation methods for user input
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Validates email format using RFC 5322 simplified pattern
  ///
  /// Returns true if email is valid, false otherwise
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }

  /// Validates phone number format (international format)
  ///
  /// Accepts formats like: +1234567890, +91 9876543210
  /// Returns true if phone number is valid, false otherwise
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    // Remove common formatting characters
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check for valid international format
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(cleanedNumber);
  }

  /// Validates vehicle registration number
  ///
  /// Returns true if vehicle number is not empty after trimming
  static bool isValidVehicleNumber(String vehicleNumber) {
    return vehicleNumber.trim().isNotEmpty;
  }

  /// Validates that a string is not empty after trimming
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  /// Validates that a value is within a range
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }
}
