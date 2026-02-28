import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/auth/domain/entities/user.dart';
import 'package:letmegoo/features/auth/domain/repositories/auth_repository.dart';

/// Use case for authenticating user
class AuthenticateUser implements UseCase<User, NoParams> {
  final AuthRepository repository;

  AuthenticateUser(this.repository);

  @override
  Future<User> call(NoParams params) async {
    return await repository.authenticateUser();
  }
}
