import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/repositories/short_link_repository.dart';
import 'package:flutter_web_app/features/short_links/domain/rules/short_link_rules.dart';

/// Validates the URL and alias, then creates the link.
class CreateShortLink {
  const CreateShortLink(this._repository);

  final ShortLinkRepository _repository;

  /// Rules run first so bad input never reaches the backend.
  Future<Result<ShortLink>> call({
    required String longUrl,
    String? alias,
  }) async {
    final urlFailure = validateLongUrl(longUrl);
    if (urlFailure != null) return Err(urlFailure);
    final aliasFailure = validateAlias(alias);
    if (aliasFailure != null) return Err(aliasFailure);
    return _repository.create(longUrl: longUrl, alias: alias);
  }
}
