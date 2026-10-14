import 'package:flutter/foundation.dart';

import 'package:flutter_web_app/core/flags/feature_flags.dart';
import 'package:flutter_web_app/features/example/data/datasources/article_remote_data_source.dart';
import 'package:flutter_web_app/features/example/data/repositories/article_repository_impl.dart';
import 'package:flutter_web_app/features/example/domain/usecases/get_article_page.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/http_short_link_backend.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/in_memory_short_link_backend.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_remote_data_source.dart';
import 'package:flutter_web_app/features/short_links/data/repositories/short_link_repository_impl.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/create_short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/list_short_links.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/resolve_short_link.dart';

/// Wires concrete implementations together by constructor injection.
class AppDependencies {
  AppDependencies._({
    required this.flags,
    required this.getArticlePage,
    required this.listShortLinks,
    required this.createShortLink,
    required this.resolveShortLink,
  });

  /// Feature toggles.
  final FeatureFlags flags;

  /// Use case that loads article pages.
  final GetArticlePage getArticlePage;

  /// Short link use cases.
  final ListShortLinks listShortLinks;
  final CreateShortLink createShortLink;
  final ResolveShortLink resolveShortLink;

  /// Builds the graph; data sources default to the offline in-process ones.
  // ponytail: offline fake data only; swap in a real HTTP data source when a backend exists.
  factory AppDependencies.create({
    FeatureFlags flags = const FakeFeatureFlags(),
    ArticleRemoteDataSource? dataSource,
    ShortLinkRemoteDataSource? shortLinkDataSource,
  }) {
    final source = dataSource ?? const FakeArticleRemoteDataSource();
    // The web build talks to the real redirect server; other platforms stay offline.
    final ShortLinkRemoteDataSource linkSource =
        shortLinkDataSource ??
        (kIsWeb ? const HttpShortLinkBackend() : InMemoryShortLinkBackend());
    final links = ShortLinkRepositoryImpl(linkSource);
    return AppDependencies._(
      flags: flags,
      getArticlePage: GetArticlePage(ArticleRepositoryImpl(source)),
      listShortLinks: ListShortLinks(links),
      createShortLink: CreateShortLink(links),
      resolveShortLink: ResolveShortLink(links),
    );
  }
}
