import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';
import 'package:flutter_web_app/features/example/domain/repositories/article_repository.dart';
import 'package:flutter_web_app/features/example/domain/usecases/get_article_page.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_bloc.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_event.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_state.dart';
import 'package:mocktail/mocktail.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  const first = Article(id: '1', title: 'A', summary: 'a');
  const second = Article(id: '2', title: 'B', summary: 'b');
  const firstPage = ArticlePage(items: [first], nextCursor: 'c1');
  const lastPage = ArticlePage(items: [second]);

  late MockArticleRepository repository;

  setUp(() {
    repository = MockArticleRepository();
  });

  ArticleListBloc buildBloc() =>
      ArticleListBloc(getArticlePage: GetArticlePage(repository));

  void stubFirstPage(Result<ArticlePage> result) {
    when(
      () => repository.fetchPage(cursor: null, limit: 10),
    ).thenAnswer((_) async => result);
  }

  void stubNextPage(String cursor, Result<ArticlePage> result) {
    when(
      () => repository.fetchPage(cursor: cursor, limit: 10),
    ).thenAnswer((_) async => result);
  }

  blocTest<ArticleListBloc, ArticleListState>(
    'started emits loading then data',
    build: buildBloc,
    setUp: () => stubFirstPage(const Ok(firstPage)),
    act: (bloc) => bloc.add(const ArticleListStarted()),
    expect: () => const [
      ArticleListLoading(),
      ArticleListData(items: [first], nextCursor: 'c1'),
    ],
  );

  blocTest<ArticleListBloc, ArticleListState>(
    'started emits loading then empty when the page has no items',
    build: buildBloc,
    setUp: () => stubFirstPage(const Ok(ArticlePage(items: []))),
    act: (bloc) => bloc.add(const ArticleListStarted()),
    expect: () => const [ArticleListLoading(), ArticleListEmpty()],
  );

  blocTest<ArticleListBloc, ArticleListState>(
    'started emits loading then error on failure',
    build: buildBloc,
    setUp: () => stubFirstPage(const Err(NetworkFailure())),
    act: (bloc) => bloc.add(const ArticleListStarted()),
    expect: () => const [
      ArticleListLoading(),
      ArticleListError(NetworkFailure()),
    ],
  );

  blocTest<ArticleListBloc, ArticleListState>(
    'retried reloads after an error',
    build: buildBloc,
    seed: () => const ArticleListError(NetworkFailure()),
    setUp: () => stubFirstPage(const Ok(firstPage)),
    act: (bloc) => bloc.add(const ArticleListRetried()),
    expect: () => const [
      ArticleListLoading(),
      ArticleListData(items: [first], nextCursor: 'c1'),
    ],
  );

  blocTest<ArticleListBloc, ArticleListState>(
    'load more appends the next page',
    build: buildBloc,
    seed: () => const ArticleListData(items: [first], nextCursor: 'c1'),
    setUp: () => stubNextPage('c1', const Ok(lastPage)),
    act: (bloc) => bloc.add(const ArticleListMoreRequested()),
    expect: () => const [
      ArticleListData(items: [first], nextCursor: 'c1', isLoadingMore: true),
      ArticleListData(items: [first, second]),
    ],
  );

  blocTest<ArticleListBloc, ArticleListState>(
    'load more failure keeps the loaded items',
    build: buildBloc,
    seed: () => const ArticleListData(items: [first], nextCursor: 'c1'),
    setUp: () => stubNextPage('c1', const Err(ServerFailure())),
    act: (bloc) => bloc.add(const ArticleListMoreRequested()),
    expect: () => const [
      ArticleListData(items: [first], nextCursor: 'c1', isLoadingMore: true),
      ArticleListData(
        items: [first],
        nextCursor: 'c1',
        loadMoreFailure: ServerFailure(),
      ),
    ],
  );

  blocTest<ArticleListBloc, ArticleListState>(
    'load more is ignored when there is no cursor',
    build: buildBloc,
    seed: () => const ArticleListData(items: [first]),
    act: (bloc) => bloc.add(const ArticleListMoreRequested()),
    expect: () => const <ArticleListState>[],
    verify: (_) => verifyNever(
      () => repository.fetchPage(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ),
  );

  blocTest<ArticleListBloc, ArticleListState>(
    'load more is ignored while already loading more',
    build: buildBloc,
    seed: () => const ArticleListData(
      items: [first],
      nextCursor: 'c1',
      isLoadingMore: true,
    ),
    act: (bloc) => bloc.add(const ArticleListMoreRequested()),
    expect: () => const <ArticleListState>[],
  );
}
