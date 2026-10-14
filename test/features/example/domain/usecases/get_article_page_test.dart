import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';
import 'package:flutter_web_app/features/example/domain/repositories/article_repository.dart';
import 'package:flutter_web_app/features/example/domain/usecases/get_article_page.dart';
import 'package:mocktail/mocktail.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  const page = ArticlePage(
    items: [Article(id: '1', title: 'A', summary: 'a')],
    nextCursor: '10',
  );
  late MockArticleRepository repository;
  late GetArticlePage useCase;

  setUp(() {
    repository = MockArticleRepository();
    useCase = GetArticlePage(repository);
  });

  test('passes cursor and limit to the repository', () async {
    when(
      () => repository.fetchPage(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Ok(page));

    await useCase(cursor: '10', limit: 5);

    verify(() => repository.fetchPage(cursor: '10', limit: 5)).called(1);
  });

  test('returns the page from the repository', () async {
    when(
      () => repository.fetchPage(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Ok(page));

    expect(await useCase(), const Ok(page));
  });

  test('returns the failure from the repository', () async {
    when(
      () => repository.fetchPage(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    expect(await useCase(), const Err<ArticlePage>(NetworkFailure()));
  });

  for (final limit in [0, -1]) {
    test('rejects limit $limit without calling the repository', () async {
      final result = await useCase(limit: limit);

      expect(result, isA<Err<ArticlePage>>());
      verifyNever(
        () => repository.fetchPage(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      );
    });
  }
}
