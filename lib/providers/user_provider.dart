import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/services/auth_service.dart';

// User data state
class UserState {
  final Map<String, dynamic>? userData;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastFetch;

  const UserState({
    this.userData, 
    this.isLoading = false, 
    this.errorMessage,
    this.lastFetch,
  });

  UserState copyWith({
    Map<String, dynamic>? userData,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastFetch,
  }) {
    return UserState(
      userData: userData ?? this.userData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastFetch: lastFetch ?? this.lastFetch,
    );
  }

  // Check if data is stale (older than 5 minutes)
  bool get isDataStale {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch!).inMinutes > 5;
  }
}

// User provider
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  Future<void> loadUserData({bool forceRefresh = false}) async {
    // Avoid redundant calls if data is fresh and not forcing refresh
    if (!forceRefresh && state.userData != null && !state.isDataStale && !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userData = await AuthService.authenticateUser();
      state = state.copyWith(
        userData: userData,
        isLoading: false,
        errorMessage: null,
        lastFetch: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow; // Re-throw for error handling at UI level if needed
    }
  }

  Future<void> refreshUserData() async {
    await loadUserData(forceRefresh: true);
  }

  void updatePrivacyPreference(String newPreference) {
    if (state.userData != null) {
      final updatedUserData = Map<String, dynamic>.from(state.userData!);
      updatedUserData['privacy_preference'] = newPreference;
      state = state.copyWith(userData: updatedUserData);
    }
  }

  void clearUserData() {
    state = const UserState();
  }

  // Helper method to get user initials
  String getUserInitials() {
    if (state.userData == null) return 'U';
    final fullname = state.userData!['fullname']?.toString() ?? '';
    if (fullname.isEmpty) return 'U';

    final names = fullname.trim().split(' ');
    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : 'U';
    } else {
      return ((names[0].isNotEmpty ? names[0][0] : '') +
              (names[1].isNotEmpty ? names[1][0] : ''))
          .toUpperCase();
    }
  }

  // Get formatted display name
  String getDisplayName() {
    if (state.userData == null) return 'Unknown User';
    return state.userData!['fullname']?.toString() ?? 'Unknown User';
  }

  // Get user email
  String getEmail() {
    if (state.userData == null) return 'No email';
    return state.userData!['email']?.toString() ?? 'No email';
  }

  // Get user phone
  String getPhone() {
    if (state.userData == null) return 'No phone';
    return state.userData!['phone_number']?.toString() ?? 'No phone';
  }

  // Get profile picture URL
  String? getProfilePicture() {
    if (state.userData == null) return null;
    return state.userData!['profile_picture']?.toString();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
