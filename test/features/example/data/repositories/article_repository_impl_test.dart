import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/data/datasources/article_remote_data_source.dart';
import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';
import 'package:flutter_web_app/features/example/data/repositories/article_repository_impl.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';
import 'package:mocktail/mocktail.dart';

class MockArticleRemoteDataSource extends Mock
    implements ArticleRemoteDataSource {}

void main() {
  late MockArticleRemoteDataSource source;
  late ArticleRepositoryImpl repository;

  setUp(() {
    source = MockArticleRemoteDataSource();
    repository = ArticleRepositoryImpl(source);
  });

  void stubThrow(Object error) {
    when(
      () => source.fetchPage(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(error);
  }

  test('returns Ok with the mapped page', () async {
    when(
      () => source.fetchPage(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => {
        'items': [
          {'id': '1', 'title': 'T', 'summary': 'S'},
        ],
        'next_cursor': null,
      },
    );

    final result = await repository.fetchPage(limit: 10);

    expect(
      result,
      const Ok(
        ArticlePage(
          items: [Article(id: '1', title: 'T', summary: 'S')],
        ),
      ),
    );
  });

  test('maps NetworkException to NetworkFailure', () async {
    stubThrow(const NetworkException());

    expect(
      await repository.fetchPage(limit: 10),
      const Err<ArticlePage>(NetworkFailure()),
    );
  });

  test('maps ServerException to ServerFailure', () async {
    stubThrow(const ServerException());

    expect(
      await repository.fetchPage(limit: 10),
      const Err<ArticlePage>(ServerFailure()),
    );
  });

  test('maps any other exception to UnexpectedFailure', () async {
    stubThrow(const FormatException('bad json'));

    expect(
      await repository.fetchPage(limit: 10),
      const Err<ArticlePage>(UnexpectedFailure()),
    );
  });

  test(
    'maps malformed payload to UnexpectedFailure without throwing',
    () async {
      when(
        () => source.fetchPage(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => {'items': 'not a list'});

      expect(
        await repository.fetchPage(limit: 10),
        const Err<ArticlePage>(UnexpectedFailure()),
      );
    },
  );
}
