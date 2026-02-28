import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/auth/domain/entities/user.dart';
import 'package:letmegoo/features/auth/domain/repositories/auth_repository.dart';

/// Use case for updating user profile
class UpdateUserProfile implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<User> call(UpdateProfileParams params) async {
    return await repository.updateUserProfile(
      fullname: params.fullname,
      email: params.email,
      phoneNumber: params.phoneNumber,
      companyName: params.companyName,
      profileImage: params.profileImage,
    );
  }
}

/// Parameters for updating user profile
class UpdateProfileParams extends Equatable {
  final String fullname;
  final String email;
  final String? phoneNumber;
  final String? companyName;
  final File? profileImage;

  const UpdateProfileParams({
    required this.fullname,
    required this.email,
    this.phoneNumber,
    this.companyName,
    this.profileImage,
  });

  @override
  List<Object?> get props => [
    fullname,
    email,
    phoneNumber,
    companyName,
    profileImage?.path,
  ];
}
