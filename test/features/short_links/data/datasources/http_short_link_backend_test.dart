import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/http_short_link_backend.dart';

void main() {
  // On the VM the platform arm is the stub, which refuses to run: the HTTP backend is web-only.
  const backend = HttpShortLinkBackend();

  test('create is routed through the platform arm', () {
    expect(
      backend.createLink(longUrl: 'https://example.com'),
      throwsA(isA<StateError>()),
    );
  });

  test('list is routed through the platform arm, with and without cursor', () {
    expect(backend.listLinks(limit: 10), throwsA(isA<StateError>()));
    expect(
      backend.listLinks(cursor: '10', limit: 10),
      throwsA(isA<StateError>()),
    );
  });

  test('resolve is routed through the platform arm', () {
    expect(backend.resolveLink('abc'), throwsA(isA<StateError>()));
  });
}
