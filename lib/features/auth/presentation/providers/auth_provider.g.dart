// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRemoteDataSourceHash() =>
    r'b6a9edd1b6c48be8564688bac362316f598b4432';

/// Remote data source provider
///
/// Copied from [authRemoteDataSource].
@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider =
    AutoDisposeProvider<AuthRemoteDataSource>.internal(
      authRemoteDataSource,
      name: r'authRemoteDataSourceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRemoteDataSourceRef = AutoDisposeProviderRef<AuthRemoteDataSource>;
String _$authRepositoryHash() => r'a015609d59a16027803f421f4b5143f58797955f';

/// Repository provider
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authenticateUserUseCaseHash() =>
    r'be07f34c29592a5f14e09de00835024137348920';

/// Use case providers
///
/// Copied from [authenticateUserUseCase].
@ProviderFor(authenticateUserUseCase)
final authenticateUserUseCaseProvider =
    AutoDisposeProvider<AuthenticateUser>.internal(
      authenticateUserUseCase,
      name: r'authenticateUserUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authenticateUserUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthenticateUserUseCaseRef = AutoDisposeProviderRef<AuthenticateUser>;
String _$updateUserProfileUseCaseHash() =>
    r'3b263dd33683e1addb0aadbc05350cd1f563abd5';

/// See also [updateUserProfileUseCase].
@ProviderFor(updateUserProfileUseCase)
final updateUserProfileUseCaseProvider =
    AutoDisposeProvider<UpdateUserProfile>.internal(
      updateUserProfileUseCase,
      name: r'updateUserProfileUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$updateUserProfileUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateUserProfileUseCaseRef = AutoDisposeProviderRef<UpdateUserProfile>;
String _$logoutUseCaseHash() => r'c6397566dd2d370b6143fca79489cb74fd5ec564';

/// See also [logoutUseCase].
@ProviderFor(logoutUseCase)
final logoutUseCaseProvider = AutoDisposeProvider<Logout>.internal(
  logoutUseCase,
  name: r'logoutUseCaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$logoutUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LogoutUseCaseRef = AutoDisposeProviderRef<Logout>;
String _$updatePrivacyUseCaseHash() =>
    r'a415a9ea19263f8c3ffdcb020c9233ba1f6c74c7';

/// See also [updatePrivacyUseCase].
@ProviderFor(updatePrivacyUseCase)
final updatePrivacyUseCaseProvider =
    AutoDisposeProvider<UpdatePrivacyPreference>.internal(
      updatePrivacyUseCase,
      name: r'updatePrivacyUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$updatePrivacyUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdatePrivacyUseCaseRef =
    AutoDisposeProviderRef<UpdatePrivacyPreference>;
String _$currentUserHash() => r'136a4c18c102e18ca31daa576123c775047eded3';

/// Provider to get current user
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$isAuthenticatedHash() => r'd7902237175e99d011c8437c179bd76127145ed7';

/// Provider to check if user is authenticated
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$isAuthLoadingHash() => r'0e6155ae5640b8f07f0de1c139aee0ed1e1addb9';

/// Provider to check if auth is loading
///
/// Copied from [isAuthLoading].
@ProviderFor(isAuthLoading)
final isAuthLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAuthLoading,
  name: r'isAuthLoadingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isAuthLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthLoadingRef = AutoDisposeProviderRef<bool>;
String _$userInitialsHash() => r'e1be2ecab50da444a1d0afe0fe663d1f42f547f8';

/// Provider to get user initials
///
/// Copied from [userInitials].
@ProviderFor(userInitials)
final userInitialsProvider = AutoDisposeProvider<String>.internal(
  userInitials,
  name: r'userInitialsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userInitialsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserInitialsRef = AutoDisposeProviderRef<String>;
String _$userDisplayNameHash() => r'f66107e09555f78c4cd3855da3aaa9dfdacaad3b';

/// Provider to get user display name
///
/// Copied from [userDisplayName].
@ProviderFor(userDisplayName)
final userDisplayNameProvider = AutoDisposeProvider<String>.internal(
  userDisplayName,
  name: r'userDisplayNameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userDisplayNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDisplayNameRef = AutoDisposeProviderRef<String>;
String _$authHash() => r'59ac330a2d4defeeaa50dfafff2b596e52906f34';

/// See also [Auth].
@ProviderFor(Auth)
final authProvider = AutoDisposeNotifierProvider<Auth, AuthState>.internal(
  Auth.new,
  name: r'authProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Auth = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
