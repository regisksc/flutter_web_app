import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link_page.dart';

/// Contract for short links; implemented in data.
abstract interface class ShortLinkRepository {
  /// Creates a link for [longUrl]; a custom [alias] is optional.
  Future<Result<ShortLink>> create({required String longUrl, String? alias});

  /// Lists links newest first, starting after [cursor], up to [limit] items.
  Future<Result<ShortLinkPage>> list({String? cursor, required int limit});

  /// Resolves [code] and counts one click.
  Future<Result<ShortLink>> resolve(String code);
}
