import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/in_memory_short_link_backend.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_exceptions.dart';

/// Backend whose generated codes come from [codes], in order.
InMemoryShortLinkBackend backendWith(List<String> codes) =>
    InMemoryShortLinkBackend(
      clock: () => DateTime.utc(2026),
      generateCode: () => codes.removeAt(0),
    );

void main() {
  group('createLink', () {
    test('creates a link with a generated code and zero clicks', () async {
      final backend = backendWith(['abc1234']);

      final json = await backend.createLink(longUrl: 'https://example.com');

      expect(json['code'], 'abc1234');
      expect(json['long_url'], 'https://example.com');
      expect(json['click_count'], 0);
      expect(json['created_at'], '2026-01-01T00:00:00.000Z');
    });

    test('uses a custom alias as the code', () async {
      final json = await backendWith(
        [],
      ).createLink(longUrl: 'https://example.com', alias: 'promo');

      expect(json['code'], 'promo');
    });

    test('creates a new link each time for the same long URL', () async {
      final backend = backendWith(['one1111', 'two2222']);

      final first = await backend.createLink(longUrl: 'https://example.com');
      final second = await backend.createLink(longUrl: 'https://example.com');

      expect(first['code'], isNot(second['code']));
    });

    test('rejects a taken alias with ConflictException', () async {
      final backend = backendWith([]);
      await backend.createLink(longUrl: 'https://example.com', alias: 'promo');

      expect(
        () =>
            backend.createLink(longUrl: 'https://example.org', alias: 'promo'),
        throwsA(isA<ConflictException>()),
      );
    });

    test('treats aliases as case-sensitive', () async {
      final backend = backendWith([]);
      await backend.createLink(longUrl: 'https://example.com', alias: 'Promo');

      final json = await backend.createLink(
        longUrl: 'https://example.org',
        alias: 'promo',
      );

      expect(json['code'], 'promo');
    });

    test('rejects a reserved alias with ValidationException', () async {
      expect(
        () => backendWith(
          [],
        ).createLink(longUrl: 'https://example.com', alias: 'api'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects a malformed alias with ValidationException', () async {
      expect(
        () => backendWith(
          [],
        ).createLink(longUrl: 'https://example.com', alias: 'a b'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects a bad long URL with ValidationException', () async {
      expect(
        () => backendWith([]).createLink(longUrl: 'ftp://example.com'),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'retries when a generated code collides and succeeds on a free one',
      () async {
        final backend = backendWith(['taken1', 'taken1', 'fresh01']);
        await backend.createLink(
          longUrl: 'https://example.com',
          alias: 'taken1',
        );

        final json = await backend.createLink(longUrl: 'https://example.org');

        expect(json['code'], 'fresh01');
      },
    );

    test(
      'gives up with ServerException after five colliding generated codes',
      () async {
        var calls = 0;
        final backend = InMemoryShortLinkBackend(
          clock: () => DateTime.utc(2026),
          generateCode: () {
            calls++;
            return 'taken1';
          },
        );
        await backend.createLink(
          longUrl: 'https://example.com',
          alias: 'taken1',
        );

        await expectLater(
          backend.createLink(longUrl: 'https://example.org'),
          throwsA(isA<ServerException>()),
        );
        expect(calls, 5);
      },
    );
  });

  group('resolveLink', () {
    test('throws NotFoundException for an unknown code', () async {
      expect(
        () => backendWith([]).resolveLink('nope'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('increments the click count on every resolve', () async {
      final backend = backendWith([]);
      await backend.createLink(longUrl: 'https://example.com', alias: 'promo');

      await backend.resolveLink('promo');
      final json = await backend.resolveLink('promo');

      expect(json['click_count'], 2);
    });
  });

  group('listLinks', () {
    Future<InMemoryShortLinkBackend> seeded() async {
      final backend = backendWith([]);
      for (final alias in ['aaa', 'bbb', 'ccc']) {
        await backend.createLink(
          longUrl: 'https://example.com/$alias',
          alias: alias,
        );
      }
      return backend;
    }

    test('lists the newest link first', () async {
      final json = await (await seeded()).listLinks(limit: 10);

      final codes = (json['items'] as List)
          .map((e) => (e as Map)['code'])
          .toList();
      expect(codes, ['ccc', 'bbb', 'aaa']);
      expect(json['next_cursor'], isNull);
    });

    test('pages with an offset cursor', () async {
      final backend = await seeded();

      final first = await backend.listLinks(limit: 2);
      final second = await backend.listLinks(
        cursor: first['next_cursor'] as String,
        limit: 2,
      );

      expect((first['items'] as List).length, 2);
      expect(first['next_cursor'], '2');
      expect((second['items'] as List).length, 1);
      expect(second['next_cursor'], isNull);
    });

    test('rejects a non-numeric cursor with ValidationException', () async {
      expect(
        () => backendWith([]).listLinks(cursor: 'abc', limit: 10),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects a non-positive limit with ValidationException', () async {
      expect(
        () => backendWith([]).listLinks(limit: 0),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  test('generated codes are 7 base62 characters', () {
    final code = generateShortCode();

    expect(code, matches(RegExp(r'^[0-9A-Za-z]{7}$')));
  });
}
