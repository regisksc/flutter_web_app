import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_exceptions.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_remote_data_source.dart';
import 'package:flutter_web_app/features/short_links/data/repositories/short_link_repository_impl.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link_page.dart';
import 'package:mocktail/mocktail.dart';

class MockShortLinkRemoteDataSource extends Mock
    implements ShortLinkRemoteDataSource {}

final _linkJson = {
  'code': 'abc1234',
  'long_url': 'https://example.com',
  'created_at': '2026-01-01T00:00:00.000Z',
  'click_count': 0,
};
final _link = ShortLink(
  code: 'abc1234',
  longUrl: 'https://example.com',
  createdAt: DateTime.utc(2026),
  clickCount: 0,
);

void main() {
  late MockShortLinkRemoteDataSource source;
  late ShortLinkRepositoryImpl repository;

  setUp(() {
    source = MockShortLinkRemoteDataSource();
    repository = ShortLinkRepositoryImpl(source);
  });

  group('exception to failure table', () {
    // Each row: the exception the source throws and the failure the repository must return.
    final rows = <(Object, Failure)>[
      (
        const ValidationException('Alias is reserved'),
        const ValidationFailure('Alias is reserved'),
      ),
      (
        const ConflictException(),
        const ConflictFailure('That alias is already taken'),
      ),
      (const NotFoundException(), const NotFoundFailure()),
      (const NetworkException(), const NetworkFailure()),
      (const ServerException(), const ServerFailure()),
      (StateError('boom'), const UnexpectedFailure()),
    ];

    for (final (exception, failure) in rows) {
      test(
        'create maps ${exception.runtimeType} to ${failure.runtimeType}',
        () async {
          when(
            () => source.createLink(
              longUrl: any(named: 'longUrl'),
              alias: any(named: 'alias'),
            ),
          ).thenThrow(exception);

          expect(
            await repository.create(longUrl: 'https://example.com'),
            Err<ShortLink>(failure),
          );
        },
      );

      test(
        'list maps ${exception.runtimeType} to ${failure.runtimeType}',
        () async {
          when(
            () => source.listLinks(
              cursor: any(named: 'cursor'),
              limit: any(named: 'limit'),
            ),
          ).thenThrow(exception);

          expect(await repository.list(limit: 10), Err<ShortLinkPage>(failure));
        },
      );

      test(
        'resolve maps ${exception.runtimeType} to ${failure.runtimeType}',
        () async {
          when(() => source.resolveLink(any())).thenThrow(exception);

          expect(await repository.resolve('abc1234'), Err<ShortLink>(failure));
        },
      );
    }
  });

  test('create returns the mapped link on success', () async {
    when(
      () => source.createLink(
        longUrl: any(named: 'longUrl'),
        alias: any(named: 'alias'),
      ),
    ).thenAnswer((_) async => _linkJson);

    expect(await repository.create(longUrl: 'https://example.com'), Ok(_link));
  });

  test('list returns the mapped page on success', () async {
    when(
      () => source.listLinks(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => {
        'items': [_linkJson],
        'next_cursor': '1',
      },
    );

    expect(
      await repository.list(limit: 10),
      Ok(ShortLinkPage(items: [_link], nextCursor: '1')),
    );
  });

  test(
    'a malformed payload becomes UnexpectedFailure without throwing',
    () async {
      when(
        () => source.resolveLink(any()),
      ).thenAnswer((_) async => {'code': 42});

      expect(
        await repository.resolve('abc1234'),
        const Err<ShortLink>(UnexpectedFailure()),
      );
    },
  );
}
