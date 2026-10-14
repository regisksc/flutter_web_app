import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link_page.dart';
import 'package:flutter_web_app/features/short_links/domain/repositories/short_link_repository.dart';

/// Loads one page of short links, newest first.
class ListShortLinks {
  const ListShortLinks(this._repository);

  final ShortLinkRepository _repository;

  /// Rejects a non-positive [limit] before asking the repository.
  Future<Result<ShortLinkPage>> call({String? cursor, int limit = 10}) async {
    if (limit <= 0) {
      return const Err(ValidationFailure('limit must be positive'));
    }
    return _repository.list(cursor: cursor, limit: limit);
  }
}
