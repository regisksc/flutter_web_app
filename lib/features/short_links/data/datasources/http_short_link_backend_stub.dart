// coverage:platform-only (VM tests cannot run this platform arm)
// Non-web platforms never construct HttpShortLinkBackend; bootstrap picks the
// in-memory fake there. This body exists only to keep the arm compiling.
Future<Map<String, dynamic>> call(
  String path,
  String method,
  Map<String, dynamic>? body,
) async {
  throw StateError('HTTP backend is web-only');
}
