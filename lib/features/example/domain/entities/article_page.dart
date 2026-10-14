import 'package:equatable/equatable.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';

/// One page of articles plus the cursor for the next page, if any.
class ArticlePage extends Equatable {
  const ArticlePage({required this.items, this.nextCursor});

  /// Articles on this page.
  final List<Article> items;

  /// Cursor for the next page; null when this is the last page.
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}
