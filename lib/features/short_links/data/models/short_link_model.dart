import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';

/// JSON shape of one link: code, long_url, created_at, click_count.
class ShortLinkModel {
  const ShortLinkModel({
    required this.code,
    required this.longUrl,
    required this.createdAt,
    required this.clickCount,
    this.shortUrl,
  });

  /// Accepts both shapes: the in-process fake (ISO time, click_count) and the
  /// HTTP server (epoch seconds, clicks, short_url).
  factory ShortLinkModel.fromJson(Map<String, dynamic> json) {
    final when = json['created_at'];
    final createdAt = when is String
        ? DateTime.parse(when)
        : DateTime.fromMillisecondsSinceEpoch(((when as num) * 1000).round());
    return ShortLinkModel(
      code: json['code'] as String,
      longUrl: json['long_url'] as String,
      createdAt: createdAt,
      clickCount: (json['click_count'] ?? json['clicks'] ?? 0) as int,
      shortUrl: json['short_url'] as String?,
    );
  }

  factory ShortLinkModel.fromEntity(ShortLink link) => ShortLinkModel(
    code: link.code,
    longUrl: link.longUrl,
    createdAt: link.createdAt,
    clickCount: link.clickCount,
  );

  final String code;
  final String longUrl;
  final DateTime createdAt;
  final int clickCount;

  /// Short URL exactly as the backend built it; null in the offline fake.
  final String? shortUrl;

  Map<String, dynamic> toJson() => {
    'code': code,
    'long_url': longUrl,
    'created_at': createdAt.toIso8601String(),
    'click_count': clickCount,
  };

  ShortLink toEntity() => ShortLink(
    code: code,
    longUrl: longUrl,
    createdAt: createdAt,
    clickCount: clickCount,
    shortUrl: shortUrl,
  );
}
