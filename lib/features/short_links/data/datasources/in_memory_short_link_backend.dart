import 'dart:math';

import 'package:flutter_web_app/features/short_links/data/datasources/short_link_exceptions.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_remote_data_source.dart';
import 'package:flutter_web_app/features/short_links/data/models/short_link_model.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/rules/short_link_rules.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';

const _base62 =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const _codeLength = 7;
const _maxCodeAttempts = 5;

/// Generates a 7-character base62 code using a secure random source.
String generateShortCode() {
  final random = Random.secure();
  return String.fromCharCodes(
    List.generate(
      _codeLength,
      (_) => _base62.codeUnitAt(random.nextInt(_base62.length)),
    ),
  );
}

// ponytail: in-process backend that behaves like an HTTP API. No network, no persistence, no auth, no rate limit; codes are not reachable on the web. Replace with a real HTTP data source once a server exists (see docs/adr/0001-in-process-backend.md).
class InMemoryShortLinkBackend implements ShortLinkRemoteDataSource {
  InMemoryShortLinkBackend({
    DateTime Function()? clock,
    String Function()? generateCode,
    this.latency = Duration.zero,
  }) : _clock = clock ?? DateTime.now,
       _generateCode = generateCode ?? generateShortCode;

  /// Simulated network delay.
  final Duration latency;

  final DateTime Function() _clock;
  final String Function() _generateCode;

  /// Newest first; new links are inserted at the front.
  final List<ShortLink> _links = [];

  @override
  Future<Map<String, dynamic>> createLink({
    required String longUrl,
    String? alias,
  }) async {
    await Future<void>.delayed(latency);
    _check(validateLongUrl(longUrl));
    _check(validateAlias(alias));

    final code = alias ?? _freshCode();
    if (alias != null && _exists(alias)) {
      throw const ConflictException();
    }
    final link = ShortLink(
      code: code,
      longUrl: longUrl,
      createdAt: _clock(),
      clickCount: 0,
    );
    _links.insert(0, link);
    return ShortLinkModel.fromEntity(link).toJson();
  }

  @override
  Future<Map<String, dynamic>> listLinks({
    String? cursor,
    required int limit,
  }) async {
    await Future<void>.delayed(latency);
    if (limit <= 0) throw const ValidationException('limit must be positive');
    final offset = _parseCursor(cursor);
    final end = (offset + limit).clamp(0, _links.length);
    final items = _links.sublist(offset.clamp(0, _links.length), end);
    return {
      'items': items.map((l) => ShortLinkModel.fromEntity(l).toJson()).toList(),
      'next_cursor': end < _links.length ? '$end' : null,
    };
  }

  @override
  Future<Map<String, dynamic>> resolveLink(String code) async {
    await Future<void>.delayed(latency);
    final index = _links.indexWhere((l) => l.code == code);
    if (index < 0) throw const NotFoundException();
    final opened = _links[index].copyWith(
      clickCount: _links[index].clickCount + 1,
    );
    _links[index] = opened;
    return ShortLinkModel.fromEntity(opened).toJson();
  }

  bool _exists(String code) => _links.any((l) => l.code == code);

  /// Retries generated codes that collide; gives up after [_maxCodeAttempts] as a server error.
  String _freshCode() {
    for (var attempt = 0; attempt < _maxCodeAttempts; attempt++) {
      final code = _generateCode();
      if (!_exists(code)) return code;
    }
    throw const ServerException();
  }

  int _parseCursor(String? cursor) {
    if (cursor == null) return 0;
    final offset = int.tryParse(cursor);
    if (offset == null || offset < 0) {
      throw const ValidationException('Invalid cursor');
    }
    return offset;
  }

  /// Turns a domain rule failure into the exception a real server would send as 400.
  void _check(Failure? failure) {
    if (failure != null) throw ValidationException(failure.message);
  }
}
