import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:letmegoo/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:letmegoo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:letmegoo/features/auth/domain/entities/user.dart';
import 'package:letmegoo/features/auth/domain/repositories/auth_repository.dart';
import 'package:letmegoo/features/auth/domain/usecases/authenticate_user.dart';
import 'package:letmegoo/features/auth/domain/usecases/logout.dart';
import 'package:letmegoo/features/auth/domain/usecases/update_privacy.dart';
import 'package:letmegoo/features/auth/domain/usecases/update_profile.dart';
import 'package:letmegoo/core/usecases/usecase.dart';

part 'auth_provider.g.dart';

// ============================================================================
// Dependency Injection Providers
// ============================================================================

/// Remote data source provider
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl();
}

/// Repository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

/// Use case providers
@riverpod
AuthenticateUser authenticateUserUseCase(Ref ref) {
  return AuthenticateUser(ref.watch(authRepositoryProvider));
}

@riverpod
UpdateUserProfile updateUserProfileUseCase(Ref ref) {
  return UpdateUserProfile(ref.watch(authRepositoryProvider));
}

@riverpod
Logout logoutUseCase(Ref ref) {
  return Logout(ref.watch(authRepositoryProvider));
}

@riverpod
UpdatePrivacyPreference updatePrivacyUseCase(Ref ref) {
  return UpdatePrivacyPreference(ref.watch(authRepositoryProvider));
}

// ============================================================================
// State Class
// ============================================================================

/// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastFetch;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.lastFetch,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastFetch,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetch: lastFetch ?? this.lastFetch,
    );
  }

  /// Check if data is stale (older than 5 minutes)
  bool get isDataStale {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch!).inMinutes > 5;
  }
}

// ============================================================================
// Main Auth Provider (Notifier)
// ============================================================================

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// Authenticate user
  Future<void> authenticate({bool forceRefresh = false}) async {
    // Avoid redundant calls if data is fresh
    if (!forceRefresh &&
        state.user != null &&
        !state.isDataStale &&
        !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final authenticateUser = ref.read(authenticateUserUseCaseProvider);
      final user = await authenticateUser(const NoParams());
      state = state.copyWith(
        user: user,
        isLoading: false,
        lastFetch: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String fullname,
    required String email,
    String? phoneNumber,
    String? companyName,
    File? profileImage,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updateProfile = ref.read(updateUserProfileUseCaseProvider);
      final user = await updateProfile(
        UpdateProfileParams(
          fullname: fullname,
          email: email,
          phoneNumber: phoneNumber,
          companyName: companyName,
          profileImage: profileImage,
        ),
      );
      state = state.copyWith(
        user: user,
        isLoading: false,
        lastFetch: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Update privacy preference
  Future<void> updatePrivacy(String privacyPreference) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatePrivacy = ref.read(updatePrivacyUseCaseProvider);
      await updatePrivacy(
        UpdatePrivacyParams(privacyPreference: privacyPreference),
      );

      // Update local state
      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(privacyPreference: privacyPreference),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase(const NoParams());
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(errorMessage: _getErrorMessage(e));
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get error message from exception
  String _getErrorMessage(dynamic error) {
    final message = error.toString().replaceAll('Exception: ', '');
    return message;
  }
}

// ============================================================================
// Convenience Providers
// ============================================================================

/// Provider to get current user
@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authProvider).user;
}

/// Provider to check if user is authenticated
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider).user != null;
}

/// Provider to check if auth is loading
@riverpod
bool isAuthLoading(Ref ref) {
  return ref.watch(authProvider).isLoading;
}

/// Provider to get user initials
@riverpod
String userInitials(Ref ref) {
  return ref.watch(authProvider).user?.initials ?? 'U';
}

/// Provider to get user display name
@riverpod
String userDisplayName(Ref ref) {
  return ref.watch(authProvider).user?.displayName ?? 'Unknown User';
}
