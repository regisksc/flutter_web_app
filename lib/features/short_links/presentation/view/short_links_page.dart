import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_app/core/url_opener.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/create_short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/list_short_links.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/resolve_short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/view/short_links_view.dart';

/// Screen entry: creates the BLoC from injected use cases and starts loading.
class ShortLinksPage extends StatelessWidget {
  const ShortLinksPage({
    super.key,
    required this.listShortLinks,
    required this.createShortLink,
    required this.resolveShortLink,
    this.urlOpener,
  });

  final ListShortLinks listShortLinks;
  final CreateShortLink createShortLink;
  final ResolveShortLink resolveShortLink;

  /// Opens the long URL of a short link; defaults to the browser opener.
  final UrlOpener? urlOpener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shortener')),
      body: BlocProvider(
        create: (_) => ShortLinksBloc(
          listShortLinks: listShortLinks,
          createShortLink: createShortLink,
          resolveShortLink: resolveShortLink,
        )..add(const ShortLinksStarted()),
        child: ShortLinksView(urlOpener: urlOpener ?? const BrowserUrlOpener()),
      ),
    );
  }
}
