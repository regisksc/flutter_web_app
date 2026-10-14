import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_bloc.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_event.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_state.dart';
import 'package:flutter_web_app/features/example/presentation/view/article_list_view.dart';
import 'package:mocktail/mocktail.dart';

class MockArticleListBloc extends MockBloc<ArticleListEvent, ArticleListState>
    implements ArticleListBloc {}

const _items = [
  Article(id: '1', title: 'First', summary: 'one'),
  Article(id: '2', title: 'Second', summary: 'two'),
];

Future<MockArticleListBloc> _pump(
  WidgetTester tester,
  ArticleListState state,
) async {
  final bloc = MockArticleListBloc();
  whenListen(bloc, const Stream<ArticleListState>.empty(), initialState: state);
  await tester.pumpWidget(
    BlocProvider<ArticleListBloc>.value(
      value: bloc,
      child: const MaterialApp(home: Scaffold(body: ArticleListView())),
    ),
  );
  return bloc;
}

void main() {
  testWidgets('loading state shows a spinner', (tester) async {
    await _pump(tester, const ArticleListLoading());

    expect(find.byKey(AppKeys.articleLoading), findsOneWidget);
  });

  testWidgets('data state shows tiles', (tester) async {
    await _pump(tester, const ArticleListData(items: _items));

    expect(find.byKey(AppKeys.articleList), findsOneWidget);
    expect(find.byKey(AppKeys.articleTile('1')), findsOneWidget);
    expect(find.byKey(AppKeys.articleTile('2')), findsOneWidget);
    expect(find.byKey(AppKeys.loadMoreButton), findsNothing);
  });

  testWidgets('empty state shows the empty message', (tester) async {
    await _pump(tester, const ArticleListEmpty());

    expect(find.byKey(AppKeys.articleEmpty), findsOneWidget);
  });

  testWidgets(
    'error state shows the message and retry sends ArticleListRetried',
    (tester) async {
      final bloc = await _pump(
        tester,
        const ArticleListError(NetworkFailure()),
      );

      expect(find.byKey(AppKeys.articleError), findsOneWidget);
      expect(find.text('No internet connection'), findsOneWidget);

      await tester.tap(find.byKey(AppKeys.retryButton));
      await tester.pump();

      verify(() => bloc.add(const ArticleListRetried())).called(1);
    },
  );

  testWidgets('tapping load more sends ArticleListMoreRequested', (
    tester,
  ) async {
    final bloc = await _pump(
      tester,
      const ArticleListData(items: _items, nextCursor: 'c1'),
    );

    expect(find.byKey(AppKeys.loadMoreButton), findsOneWidget);

    await tester.tap(find.byKey(AppKeys.loadMoreButton));
    await tester.pump();

    verify(() => bloc.add(const ArticleListMoreRequested())).called(1);
  });

  testWidgets('load more shows a spinner while loading more', (tester) async {
    await _pump(
      tester,
      const ArticleListData(
        items: _items,
        nextCursor: 'c1',
        isLoadingMore: true,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(AppKeys.loadMoreButton), findsNothing);
  });
}
