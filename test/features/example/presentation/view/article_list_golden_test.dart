import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app_theme.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_bloc.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_event.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_state.dart';
import 'package:flutter_web_app/features/example/presentation/view/article_list_view.dart';

class _MockArticleListBloc extends MockBloc<ArticleListEvent, ArticleListState>
    implements ArticleListBloc {}

void main() {
  testWidgets('article list data state golden', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bloc = _MockArticleListBloc();
    const state = ArticleListData(
      items: [
        Article(
          id: '1',
          title: 'Clean architecture',
          summary: 'Layers and dependency rules.',
        ),
        Article(
          id: '2',
          title: 'BLoC basics',
          summary: 'Events in, states out.',
        ),
        Article(
          id: '3',
          title: 'Failures as values',
          summary: 'No exceptions past data.',
        ),
      ],
      nextCursor: 'c1',
    );
    whenListen(
      bloc,
      const Stream<ArticleListState>.empty(),
      initialState: state,
    );

    await tester.pumpWidget(
      BlocProvider<ArticleListBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ArticleListView()),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(ArticleListView),
      matchesGoldenFile('goldens/article_list_data.png'),
    );
  });
}
