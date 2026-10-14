import 'package:equatable/equatable.dart';

/// A short link: a code that points at a long URL and counts its clicks.
class ShortLink extends Equatable {
  const ShortLink({
    required this.code,
    required this.longUrl,
    required this.createdAt,
    required this.clickCount,
  });

  /// Case-sensitive code used in the short URL.
  final String code;

  /// Destination the short link sends people to.
  final String longUrl;

  /// When the link was created; drives newest-first ordering.
  final DateTime createdAt;

  /// Number of times the link was opened (simulated redirect hits).
  final int clickCount;

  /// Public short URL, for example https://sho.rt/abc1234.
  String get shortUrl => 'https://sho.rt/$code';

  /// Copy with a new click count; used when a link is opened.
  ShortLink copyWith({int? clickCount}) => ShortLink(
    code: code,
    longUrl: longUrl,
    createdAt: createdAt,
    clickCount: clickCount ?? this.clickCount,
  );

  @override
  List<Object?> get props => [code, longUrl, createdAt, clickCount];
}
