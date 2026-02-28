import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/auth/domain/repositories/auth_repository.dart';

/// Use case for logging out user
class Logout implements UseCase<void, NoParams> {
  final AuthRepository repository;

  Logout(this.repository);

  @override
  Future<void> call(NoParams params) async {
    await repository.logout();
  }
}
