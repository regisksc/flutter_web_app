import 'dart:math';

/// Raw page source; returns decoded JSON.
abstract interface class ArticleRemoteDataSource {
  /// Fetches the raw page after [cursor].
  Future<Map<String, dynamic>> fetchPage({String? cursor, required int limit});
}

/// Generates articles locally; the cursor is the offset as a string.
// ponytail: generated offline data; replace with a real HTTP source when a backend exists.
class FakeArticleRemoteDataSource implements ArticleRemoteDataSource {
  const FakeArticleRemoteDataSource({
    this.latency = Duration.zero,
    this.total = 25,
  });

  /// Simulated network delay.
  final Duration latency;

  /// Number of articles that exist in total.
  final int total;

  @override
  Future<Map<String, dynamic>> fetchPage({
    String? cursor,
    required int limit,
  }) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    final start = int.tryParse(cursor ?? '0') ?? 0;
    final end = min(start + limit, total);
    return {
      'items': [
        for (var i = start; i < end; i++)
          {
            'id': '$i',
            'title': 'Article ${i + 1}',
            'summary': 'Summary for article ${i + 1}',
          },
      ],
      'next_cursor': end < total ? '$end' : null,
    };
  }
}
