import 'package:equatable/equatable.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/auth/domain/repositories/auth_repository.dart';

/// Use case for updating privacy preference
class UpdatePrivacyPreference implements UseCase<void, UpdatePrivacyParams> {
  final AuthRepository repository;

  UpdatePrivacyPreference(this.repository);

  @override
  Future<void> call(UpdatePrivacyParams params) async {
    await repository.updatePrivacyPreference(params.privacyPreference);
  }
}

/// Parameters for updating privacy preference
class UpdatePrivacyParams extends Equatable {
  final String privacyPreference;

  const UpdatePrivacyParams({required this.privacyPreference});

  @override
  List<Object?> get props => [privacyPreference];
}
