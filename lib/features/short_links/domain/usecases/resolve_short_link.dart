import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/repositories/short_link_repository.dart';

/// Opens a short link by code and counts the click.
class ResolveShortLink {
  const ResolveShortLink(this._repository);

  final ShortLinkRepository _repository;

  Future<Result<ShortLink>> call(String code) async {
    if (code.trim().isEmpty) {
      return const Err(ValidationFailure('Code is required'));
    }
    return _repository.resolve(code);
  }
}
