import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';

/// Contract for loading articles; implemented in data.
abstract interface class ArticleRepository {
  /// Fetches the page after [cursor] holding up to [limit] articles.
  Future<Result<ArticlePage>> fetchPage({String? cursor, required int limit});
}
