import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/repositories/short_link_repository.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/resolve_short_link.dart';
import 'package:mocktail/mocktail.dart';

class MockShortLinkRepository extends Mock implements ShortLinkRepository {}

void main() {
  final link = ShortLink(
    code: 'abc1234',
    longUrl: 'https://example.com',
    createdAt: DateTime(2026),
    clickCount: 1,
  );
  late MockShortLinkRepository repository;
  late ResolveShortLink useCase;

  setUp(() {
    repository = MockShortLinkRepository();
    useCase = ResolveShortLink(repository);
  });

  for (final code in ['', '   ']) {
    test('rejects blank code "$code" without calling the repository', () async {
      final result = await useCase(code);

      expect(
        result,
        isA<Err<ShortLink>>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      );
      verifyNever(() => repository.resolve(any()));
    });
  }

  test('resolves the code through the repository', () async {
    when(() => repository.resolve('abc1234')).thenAnswer((_) async => Ok(link));

    expect(await useCase('abc1234'), Ok(link));
  });

  test('returns NotFoundFailure from the repository', () async {
    when(
      () => repository.resolve('nope'),
    ).thenAnswer((_) async => const Err(NotFoundFailure()));

    expect(await useCase('nope'), const Err<ShortLink>(NotFoundFailure()));
  });
}
