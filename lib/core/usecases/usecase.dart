import 'package:equatable/equatable.dart';

/// Base use case interface
///
/// All use cases should implement this interface.
/// [T] is the return type of the use case.
/// [Params] is the parameters required by the use case.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use this when the use case doesn't require any parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
