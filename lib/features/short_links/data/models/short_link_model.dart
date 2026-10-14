import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';

/// JSON shape of one link: code, long_url, created_at, click_count.
class ShortLinkModel {
  const ShortLinkModel({
    required this.code,
    required this.longUrl,
    required this.createdAt,
    required this.clickCount,
  });

  factory ShortLinkModel.fromJson(Map<String, dynamic> json) => ShortLinkModel(
    code: json['code'] as String,
    longUrl: json['long_url'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    clickCount: json['click_count'] as int,
  );

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
  );
}
