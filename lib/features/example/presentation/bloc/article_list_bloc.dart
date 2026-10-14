import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/features/example/domain/usecases/get_article_page.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_event.dart';
import 'package:flutter_web_app/features/example/presentation/bloc/article_list_state.dart';

/// Drives the article list: first page, retry, and cursor-based load more.
class ArticleListBloc extends Bloc<ArticleListEvent, ArticleListState> {
  ArticleListBloc({required GetArticlePage getArticlePage})
    : _getArticlePage = getArticlePage,
      super(const ArticleListLoading()) {
    on<ArticleListStarted>(_onFirstPage);
    on<ArticleListRetried>(_onFirstPage);
    on<ArticleListMoreRequested>(_onMore);
  }

  /// Articles per request.
  static const pageSize = 10;

  final GetArticlePage _getArticlePage;

  Future<void> _onFirstPage(
    ArticleListEvent event,
    Emitter<ArticleListState> emit,
  ) async {
    emit(const ArticleListLoading());
    final result = await _getArticlePage(limit: pageSize);
    emit(
      result.when<ArticleListState>(
        ok: (page) => page.items.isEmpty
            ? const ArticleListEmpty()
            : ArticleListData(items: page.items, nextCursor: page.nextCursor),
        err: (failure) => ArticleListError(failure),
      ),
    );
  }

  Future<void> _onMore(
    ArticleListMoreRequested event,
    Emitter<ArticleListState> emit,
  ) async {
    final current = state;
    if (current is! ArticleListData ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return;
    }
    emit(
      ArticleListData(
        items: current.items,
        nextCursor: current.nextCursor,
        isLoadingMore: true,
      ),
    );
    final result = await _getArticlePage(
      cursor: current.nextCursor,
      limit: pageSize,
    );
    emit(
      result.when<ArticleListState>(
        ok: (page) => ArticleListData(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
        err: (failure) => _keepItems(current, failure),
      ),
    );
  }

  ArticleListData _keepItems(ArticleListData current, Failure failure) =>
      ArticleListData(
        items: current.items,
        nextCursor: current.nextCursor,
        loadMoreFailure: failure,
      );
}
