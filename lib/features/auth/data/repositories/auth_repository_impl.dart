import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letmegoo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:letmegoo/features/auth/domain/entities/user.dart';
import 'package:letmegoo/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final firebase.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  User? _cachedUser;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    firebase.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
       googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<User> authenticateUser() async {
    final userDto = await remoteDataSource.authenticateUser();
    _cachedUser = userDto.toEntity();
    return _cachedUser!;
  }

  @override
  Future<User> updateUserProfile({
    required String fullname,
    required String email,
    String? phoneNumber,
    String? companyName,
    File? profileImage,
  }) async {
    final userDto = await remoteDataSource.updateUserProfile(
      fullname: fullname,
      email: email,
      phoneNumber: phoneNumber,
      companyName: companyName,
      profileImage: profileImage,
    );
    _cachedUser = userDto.toEntity();
    return _cachedUser!;
  }

  @override
  Future<void> updateUserStatus(String newStatus) async {
    await remoteDataSource.updateUserStatus(newStatus);
  }

  @override
  Future<void> updatePrivacyPreference(String privacyPreference) async {
    await remoteDataSource.updatePrivacyPreference(privacyPreference);
    if (_cachedUser != null) {
      _cachedUser = _cachedUser!.copyWith(privacyPreference: privacyPreference);
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    await remoteDataSource.deleteUserAccount();
    await _signOutFromProviders();
    _cachedUser = null;
  }

  @override
  Future<void> logout() async {
    await _signOutFromProviders();
    _cachedUser = null;
  }

  @override
  User? getCachedUser() => _cachedUser;

  @override
  void clearCache() {
    _cachedUser = null;
  }

  /// Sign out from Firebase and Google
  Future<void> _signOutFromProviders() async {
    await firebaseAuth.signOut();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }
}
