import 'package:equatable/equatable.dart';

/// A short link: a code that points at a long URL and counts its clicks.
class ShortLink extends Equatable {
  const ShortLink({
    required this.code,
    required this.longUrl,
    required this.createdAt,
    required this.clickCount,
    String? shortUrl,
  }) : _shortUrl = shortUrl;

  /// Case-sensitive code used in the short URL.
  final String code;

  /// Destination the short link sends people to.
  final String longUrl;

  /// When the link was created; drives newest-first ordering.
  final DateTime createdAt;

  /// Number of times the link was opened (redirect hits).
  final int clickCount;

  /// Short URL exactly as the backend built it; null for the offline fake.
  final String? _shortUrl;

  /// Public short URL: the backend's own (real host) or the offline placeholder.
  String get shortUrl => _shortUrl ?? 'https://sho.rt/$code';

  /// Copy with a new click count; used when a link is opened.
  ShortLink copyWith({int? clickCount}) => ShortLink(
    code: code,
    longUrl: longUrl,
    createdAt: createdAt,
    clickCount: clickCount ?? this.clickCount,
    shortUrl: _shortUrl,
  );

  @override
  List<Object?> get props => [code, longUrl, createdAt, clickCount, _shortUrl];
}
