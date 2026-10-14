import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/data/datasources/article_remote_data_source.dart';
import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';
import 'package:flutter_web_app/features/example/data/models/article_page_model.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';
import 'package:flutter_web_app/features/example/domain/repositories/article_repository.dart';

/// Repository backed by a remote source; exceptions never leave this class.
class ArticleRepositoryImpl implements ArticleRepository {
  const ArticleRepositoryImpl(this._dataSource);

  final ArticleRemoteDataSource _dataSource;

  @override
  Future<Result<ArticlePage>> fetchPage({
    String? cursor,
    required int limit,
  }) async {
    try {
      final json = await _dataSource.fetchPage(cursor: cursor, limit: limit);
      return Ok(ArticlePageModel.fromJson(json).toEntity());
    } on NetworkException {
      return const Err(NetworkFailure());
    } on ServerException {
      return const Err(ServerFailure());
    } catch (_) {
      // Malformed JSON (TypeError, FormatException) lands here on purpose.
      return const Err(UnexpectedFailure());
    }
  }
}
