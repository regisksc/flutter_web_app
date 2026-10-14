import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_exceptions.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_remote_data_source.dart';
import 'package:flutter_web_app/features/short_links/data/models/short_link_model.dart';
import 'package:flutter_web_app/features/short_links/data/models/short_link_page_model.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link_page.dart';
import 'package:flutter_web_app/features/short_links/domain/repositories/short_link_repository.dart';

/// Repository backed by the remote source; exceptions never leave this class.
class ShortLinkRepositoryImpl implements ShortLinkRepository {
  const ShortLinkRepositoryImpl(this._dataSource);

  final ShortLinkRemoteDataSource _dataSource;

  @override
  Future<Result<ShortLink>> create({required String longUrl, String? alias}) =>
      _guard(() async {
        final json = await _dataSource.createLink(
          longUrl: longUrl,
          alias: alias,
        );
        return ShortLinkModel.fromJson(json).toEntity();
      });

  @override
  Future<Result<ShortLinkPage>> list({String? cursor, required int limit}) =>
      _guard(() async {
        final json = await _dataSource.listLinks(cursor: cursor, limit: limit);
        return ShortLinkPageModel.fromJson(json).toEntity();
      });

  @override
  Future<Result<ShortLink>> resolve(String code) => _guard(() async {
    final json = await _dataSource.resolveLink(code);
    return ShortLinkModel.fromJson(json).toEntity();
  });

  /// Runs [call] and maps every exception to a Failure value.
  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on ValidationException catch (e) {
      return Err<T>(ValidationFailure(e.message));
    } on ConflictException catch (e) {
      return Err<T>(ConflictFailure(e.message));
    } on NotFoundException {
      return Err<T>(NotFoundFailure());
    } on NetworkException {
      return Err<T>(NetworkFailure());
    } on ServerException {
      return Err<T>(ServerFailure());
      // Malformed JSON (TypeError, FormatException) lands here on purpose.
    } catch (_) {
      return Err<T>(UnexpectedFailure());
    }
  }
}
