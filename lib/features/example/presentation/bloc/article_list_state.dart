import 'package:equatable/equatable.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';

/// Screen states of the article list.
sealed class ArticleListState extends Equatable {
  const ArticleListState();
}

/// First page is loading.
final class ArticleListLoading extends ArticleListState {
  const ArticleListLoading();

  @override
  List<Object?> get props => const [];
}

/// Loaded page with articles; [loadMoreFailure] keeps items visible when paging fails.
final class ArticleListData extends ArticleListState {
  const ArticleListData({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  /// Articles loaded so far.
  final List<Article> items;

  /// Cursor for the next page, or null when there is none.
  final String? nextCursor;

  /// True while the next page is being fetched.
  final bool isLoadingMore;

  /// Set when the last load-more attempt failed.
  final Failure? loadMoreFailure;

  @override
  List<Object?> get props => [
    items,
    nextCursor,
    isLoadingMore,
    loadMoreFailure,
  ];
}

/// The source returned no articles.
final class ArticleListEmpty extends ArticleListState {
  const ArticleListEmpty();

  @override
  List<Object?> get props => const [];
}

/// The first page failed to load.
final class ArticleListError extends ArticleListState {
  const ArticleListError(this.failure);

  /// Why loading failed.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
