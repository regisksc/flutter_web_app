import 'package:flutter/material.dart';
import 'package:flutter_web_app/app/app_theme.dart';
import 'package:flutter_web_app/app/bootstrap.dart';
import 'package:flutter_web_app/core/flags/feature_flags.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/example/presentation/view/article_list_page.dart';
import 'package:flutter_web_app/features/short_links/presentation/view/short_links_page.dart';

/// Root widget; picks the screen from feature flags (short links first).
class App extends StatelessWidget {
  const App({super.key, required this.dependencies});

  /// Wired dependencies for the whole app.
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    final enabled = dependencies.flags.isEnabled(Flag.articleList);
    final shortLinks = dependencies.flags.isEnabled(Flag.shortLinks);
    return MaterialApp(
      title: 'Outsmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: shortLinks
          ? ShortLinksPage(
              listShortLinks: dependencies.listShortLinks,
              createShortLink: dependencies.createShortLink,
              resolveShortLink: dependencies.resolveShortLink,
            )
          : enabled
          ? ArticleListPage(getArticlePage: dependencies.getArticlePage)
          : const Scaffold(
              body: Center(
                child: Text('Feature disabled', key: AppKeys.featureDisabled),
              ),
            ),
    );
  }
}
