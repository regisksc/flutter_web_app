/// Network is unreachable; converted to NetworkFailure by the repository.
class NetworkException implements Exception {
  const NetworkException();
}

/// Server returned an error; converted to ServerFailure by the repository.
class ServerException implements Exception {
  const ServerException();
}
