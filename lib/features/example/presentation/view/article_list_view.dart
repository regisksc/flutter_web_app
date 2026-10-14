import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_app/core/design_system/components/app_button.dart';
import 'package:flutter_web_app/core/design_system/components/error_view.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_spacing.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_bloc.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_event.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_state.dart';
import 'package:flutter_web_app/features/example/presentation/widgets/article_tile.dart';

/// Renders each [ArticleListState] of the article list.
class ArticleListView extends StatelessWidget {
  const ArticleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleListBloc, ArticleListState>(
      builder: (context, state) => switch (state) {
        ArticleListLoading() => const Center(
          child: CircularProgressIndicator(key: AppKeys.articleLoading),
        ),
        ArticleListEmpty() => const Center(
          child: Text('No articles yet', key: AppKeys.articleEmpty),
        ),
        ArticleListError(:final failure) => ErrorView(
          key: AppKeys.articleError,
          message: failure.message,
          onRetry: () =>
              context.read<ArticleListBloc>().add(const ArticleListRetried()),
        ),
        ArticleListData() => _DataList(state: state),
      },
    );
  }
}

class _DataList extends StatelessWidget {
  const _DataList({required this.state});

  final ArticleListData state;

  @override
  Widget build(BuildContext context) {
    final cursor = state.nextCursor;
    final failure = state.loadMoreFailure;
    return ListView(
      key: AppKeys.articleList,
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final article in state.items) ArticleTile(article: article),
        if (failure != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(failure.message, textAlign: TextAlign.center),
          ),
        if (cursor != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: state.isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    key: AppKeys.loadMoreButton,
                    label: 'Load more',
                    onPressed: () => context.read<ArticleListBloc>().add(
                      const ArticleListMoreRequested(),
                    ),
                  ),
          ),
      ],
    );
  }
}
