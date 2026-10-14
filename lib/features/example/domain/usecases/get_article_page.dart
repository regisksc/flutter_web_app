import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';
import 'package:flutter_web_app/features/example/domain/repositories/article_repository.dart';

/// Loads one page of articles and enforces the page-size rule.
class GetArticlePage {
  const GetArticlePage(this._repository);

  final ArticleRepository _repository;

  /// Returns a failure without asking the repository when [limit] is not positive.
  Future<Result<ArticlePage>> call({String? cursor, int limit = 10}) async {
    if (limit <= 0) {
      return const Err(UnexpectedFailure('limit must be positive'));
    }
    return _repository.fetchPage(cursor: cursor, limit: limit);
  }
}
