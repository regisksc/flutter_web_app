import 'package:equatable/equatable.dart';

/// Expected, user-facing error value; exceptions become failures at the data boundary.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Human-readable description shown to the user.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Connectivity or transport problem.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// The server answered with an error.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

/// Anything else, such as malformed data.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong']);
}

/// Input broke a rule, such as a malformed URL or a reserved alias.
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input']);
}

/// The requested value already exists, such as a taken alias.
final class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Already taken']);
}

/// No item exists for the requested key.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}
