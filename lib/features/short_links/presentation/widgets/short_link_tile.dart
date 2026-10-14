import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_app/core/design_system/components/app_card.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_spacing.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_typography.dart';
import 'package:flutter_web_app/core/url_opener.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';

/// One short link: short URL, long URL, click count, copy and open actions.
class ShortLinkTile extends StatelessWidget {
  ShortLinkTile({required this.link, this.opener})
    : super(key: AppKeys.shortLinkTile(link.code));

  final ShortLink link;

  /// Opens the long URL (the real destination); absent in plain widget test set-ups.
  final UrlOpener? opener;

  /// Open taps the same affordance as the button: go to the long URL + count a click.
  void _open(BuildContext context) {
    opener?.open(link.longUrl);
    context.read<ShortLinksBloc>().add(ShortLinkOpened(link.code));
  }

  @override
  Widget build(BuildContext context) {
    final clicks = link.clickCount;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _open(context),
                  child: Text(link.shortUrl, style: AppTypography.title),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  link.longUrl,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  clicks == 1 ? '1 click' : '$clicks clicks',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          IconButton(
            key: AppKeys.copyButton(link.code),
            tooltip: 'Copy',
            icon: const Icon(Icons.copy),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: link.shortUrl)),
          ),
          IconButton(
            key: AppKeys.openButton(link.code),
            tooltip: 'Open (counts a click)',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _open(context),
          ),
        ],
      ),
    );
  }
}
