import 'package:flutter_web_app/features/short_links/data/datasources/in_memory_short_link_backend.dart';

/// Raw short-link source; every method returns decoded JSON and throws data exceptions on failure.
/// [InMemoryShortLinkBackend] is the only implementation today.
abstract interface class ShortLinkRemoteDataSource {
  /// Creates a link; throws ValidationException, ConflictException or ServerException.
  Future<Map<String, dynamic>> createLink({
    required String longUrl,
    String? alias,
  });

  /// Lists links newest first; throws ValidationException for a bad cursor or limit.
  Future<Map<String, dynamic>> listLinks({String? cursor, required int limit});

  /// Resolves a code and counts a click; throws NotFoundException for an unknown code.
  Future<Map<String, dynamic>> resolveLink(String code);
}
