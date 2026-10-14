import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/repositories/short_link_repository.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/create_short_link.dart';
import 'package:mocktail/mocktail.dart';

class MockShortLinkRepository extends Mock implements ShortLinkRepository {}

void main() {
  final link = ShortLink(
    code: 'abc1234',
    longUrl: 'https://example.com',
    createdAt: DateTime(2026),
    clickCount: 0,
  );
  late MockShortLinkRepository repository;
  late CreateShortLink useCase;

  setUp(() {
    repository = MockShortLinkRepository();
    useCase = CreateShortLink(repository);
  });

  test('creates the link through the repository when input is valid', () async {
    when(
      () => repository.create(
        longUrl: any(named: 'longUrl'),
        alias: any(named: 'alias'),
      ),
    ).thenAnswer((_) async => Ok(link));

    final result = await useCase(
      longUrl: 'https://example.com',
      alias: 'promo',
    );

    expect(result, Ok(link));
    verify(
      () => repository.create(longUrl: 'https://example.com', alias: 'promo'),
    ).called(1);
  });

  test('passes a null alias through when none is given', () async {
    when(
      () => repository.create(
        longUrl: any(named: 'longUrl'),
        alias: any(named: 'alias'),
      ),
    ).thenAnswer((_) async => Ok(link));

    await useCase(longUrl: 'https://example.com');

    verify(
      () => repository.create(longUrl: 'https://example.com', alias: null),
    ).called(1);
  });

  test(
    'returns ValidationFailure for a bad URL without calling the repository',
    () async {
      final result = await useCase(longUrl: 'ftp://example.com');

      expect(
        result,
        isA<Err<ShortLink>>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      );
      verifyNever(
        () => repository.create(
          longUrl: any(named: 'longUrl'),
          alias: any(named: 'alias'),
        ),
      );
    },
  );

  test(
    'returns ValidationFailure for a reserved alias without calling the repository',
    () async {
      final result = await useCase(
        longUrl: 'https://example.com',
        alias: 'admin',
      );

      expect(
        result,
        isA<Err<ShortLink>>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      );
      verifyNever(
        () => repository.create(
          longUrl: any(named: 'longUrl'),
          alias: any(named: 'alias'),
        ),
      );
    },
  );

  test('returns the repository failure, such as a taken alias', () async {
    when(
      () => repository.create(
        longUrl: any(named: 'longUrl'),
        alias: any(named: 'alias'),
      ),
    ).thenAnswer((_) async => const Err(ConflictFailure()));

    expect(
      await useCase(longUrl: 'https://example.com', alias: 'taken'),
      const Err<ShortLink>(ConflictFailure()),
    );
  });
}
