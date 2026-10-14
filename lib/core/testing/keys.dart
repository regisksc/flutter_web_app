import 'package:flutter/widgets.dart';

/// Stable widget keys shared by the app and its tests.
abstract final class AppKeys {
  static const Key articleList = Key('article.list');
  static const Key articleLoading = Key('article.loading');
  static const Key articleEmpty = Key('article.empty');
  static const Key articleError = Key('article.error');
  static const Key retryButton = Key('article.retry');
  static const Key loadMoreButton = Key('article.loadMore');
  static const Key featureDisabled = Key('feature.disabled');

  /// Key for the tile of the article with [id].
  static Key articleTile(String id) => ValueKey('article.tile.$id');

  static const Key latestResult = Key('shortLinks.latestResult');
  static const Key urlField = Key('shortLinks.urlField');
  static const Key aliasField = Key('shortLinks.aliasField');
  static const Key shortenButton = Key('shortLinks.shorten');
  static const Key actionError = Key('shortLinks.actionError');
  static const Key shortLinksLoading = Key('shortLinks.loading');
  static const Key shortLinksEmpty = Key('shortLinks.empty');
  static const Key shortLinksError = Key('shortLinks.error');
  static const Key shortLinksList = Key('shortLinks.list');
  static const Key shortLinksLoadMore = Key('shortLinks.loadMore');

  /// Key for the tile of the short link with [code].
  static Key shortLinkTile(String code) => ValueKey('shortLinks.tile.$code');

  /// Copy-to-clipboard button of the short link with [code].
  static Key copyButton(String code) => ValueKey('shortLinks.copy.$code');

  /// Open button of the short link with [code].
  static Key openButton(String code) => ValueKey('shortLinks.open.$code');
}
