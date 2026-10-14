import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_app/features/example/domain/usecases/get_article_page.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_bloc.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_event.dart';
import 'package:flutter_web_app/features/example/presentation/view/article_list_view.dart';

/// Screen entry: creates the BLoC and starts loading.
class ArticleListPage extends StatelessWidget {
  const ArticleListPage({super.key, required this.getArticlePage});

  /// Use case injected from the app root.
  final GetArticlePage getArticlePage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: BlocProvider(
        create: (_) =>
            ArticleListBloc(getArticlePage: getArticlePage)
              ..add(const ArticleListStarted()),
        child: const ArticleListView(),
      ),
    );
  }
}
