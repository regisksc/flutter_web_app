import 'http_short_link_backend_stub.dart'
    if (dart.library.html) 'http_short_link_backend_web.dart'
    as backend;

import 'short_link_remote_data_source.dart';

/// Real backend served by tool/redirect_server.py over HTTP (same interface as
/// the in-memory fake). Throws data exceptions like the fake; the repository
/// keeps converting them to Failure.
class HttpShortLinkBackend implements ShortLinkRemoteDataSource {
  const HttpShortLinkBackend();

  @override
  Future<Map<String, dynamic>> createLink({
    required String longUrl,
    String? alias,
  }) {
    return backend.call('/api/shorten', 'POST', {
      'long_url': longUrl,
      'alias': alias,
    });
  }

  @override
  Future<Map<String, dynamic>> listLinks({String? cursor, required int limit}) {
    final query = cursor == null
        ? 'limit=$limit'
        : 'cursor=$cursor&limit=$limit';
    return backend.call('/api/links?$query', 'GET', null);
  }

  @override
  Future<Map<String, dynamic>> resolveLink(String code) {
    return backend.call('/api/links/$code', 'GET', null);
  }
}
