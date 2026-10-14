import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link_page.dart';
import 'package:flutter_web_app/features/short_links/domain/repositories/short_link_repository.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/list_short_links.dart';
import 'package:mocktail/mocktail.dart';

class MockShortLinkRepository extends Mock implements ShortLinkRepository {}

void main() {
  const page = ShortLinkPage(items: [], nextCursor: '10');
  late MockShortLinkRepository repository;
  late ListShortLinks useCase;

  setUp(() {
    repository = MockShortLinkRepository();
    useCase = ListShortLinks(repository);
  });

  test('passes cursor and limit to the repository', () async {
    when(
      () => repository.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Ok(page));

    await useCase(cursor: '10', limit: 5);

    verify(() => repository.list(cursor: '10', limit: 5)).called(1);
  });

  test('uses a page size of 10 by default', () async {
    when(
      () => repository.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Ok(page));

    await useCase();

    verify(() => repository.list(cursor: null, limit: 10)).called(1);
  });

  test('returns the page from the repository', () async {
    when(
      () => repository.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Ok(page));

    expect(await useCase(), const Ok(page));
  });

  for (final limit in [0, -1]) {
    test('rejects limit $limit without calling the repository', () async {
      final result = await useCase(limit: limit);

      expect(result, isA<Err<ShortLinkPage>>());
      verifyNever(
        () => repository.list(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      );
    });
  }

  test('returns the failure from the repository', () async {
    when(
      () => repository.list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    expect(await useCase(), const Err<ShortLinkPage>(NetworkFailure()));
  });
}
