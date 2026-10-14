/// Input broke a rule; stands for an HTTP 400 from a real server. The repository keeps [message].
class ValidationException implements Exception {
  const ValidationException(this.message);

  /// Human-readable reason, shown to the user.
  final String message;
}

/// Alias already in use; stands for an HTTP 409.
class ConflictException implements Exception {
  const ConflictException([this.message = 'That alias is already taken']);

  /// Human-readable reason, shown to the user.
  final String message;
}

/// No link exists for the code; stands for an HTTP 404.
class NotFoundException implements Exception {
  const NotFoundException();
}
