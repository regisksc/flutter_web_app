import 'package:flutter_web_app/features/example/data/models/article_model.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';

/// JSON shape of one page; the mapper to the domain entity lives here.
class ArticlePageModel {
  const ArticlePageModel({required this.items, required this.nextCursor});

  factory ArticlePageModel.fromJson(Map<String, dynamic> json) {
    return ArticlePageModel(
      items: (json['items'] as List<dynamic>)
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  /// Articles on this page.
  final List<ArticleModel> items;

  /// Cursor for the next page, or null.
  final String? nextCursor;

  /// Maps to the domain entity.
  ArticlePage toEntity() => ArticlePage(
    items: [for (final item in items) item.toEntity()],
    nextCursor: nextCursor,
  );
}
