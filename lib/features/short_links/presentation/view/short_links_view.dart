import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_app/core/design_system/components/app_button.dart';
import 'package:flutter_web_app/core/design_system/components/app_card.dart';
import 'package:flutter_web_app/core/design_system/components/error_view.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_spacing.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_typography.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/core/url_opener.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_state.dart';
import 'package:flutter_web_app/features/short_links/presentation/widgets/short_link_tile.dart';

/// Form + latest result + list of short links; renders every bloc state.
class ShortLinksView extends StatefulWidget {
  const ShortLinksView({super.key, this.urlOpener});

  /// Hand to every tile; null means the caller must not open a browser (tests).
  final UrlOpener? urlOpener;

  @override
  State<ShortLinksView> createState() => _ShortLinksViewState();
}

class _ShortLinksViewState extends State<ShortLinksView> {
  final _url = TextEditingController();
  final _alias = TextEditingController();
  ShortLink? _latest;
  ShortLinksState? _prev;

  @override
  void dispose() {
    _url.dispose();
    _alias.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final alias = _alias.text.trim();
    context.read<ShortLinksBloc>().add(
      ShortLinkSubmitted(
        longUrl: _url.text.trim(),
        alias: alias.isEmpty ? null : alias,
      ),
    );
  }

  /// Clear the form and show the new link, after the current frame.
  void _onCreated(ShortLink link) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _url.clear();
      _alias.clear();
      setState(() => _latest = link);
    });
  }

  /// A create finished: a new link is now first in the list. The builder can skip the
  /// intermediate "creating" state (it only sees the last state per frame), so compare list heads.
  bool _createSucceeded(ShortLinksState? prev, ShortLinksState curr) {
    final before = switch (prev) {
      ShortLinksEmpty() => const <ShortLink>[],
      ShortLinksData(:final items) => items,
      _ => null, // loading/error/first build: not a create
    };
    return before != null &&
        curr is ShortLinksData &&
        curr.actionFailure == null &&
        curr.items.length > before.length &&
        (before.isEmpty || curr.items.first.code != before.first.code);
  }

  @override
  Widget build(BuildContext context) {
    // One subscription to the bloc only: the create-finished transition is detected in the builder.
    return BlocBuilder<ShortLinksBloc, ShortLinksState>(
      builder: (context, state) {
        if (_createSucceeded(_prev, state)) {
          _onCreated((state as ShortLinksData).items.first);
        }
        _prev = state;
        return switch (state) {
          ShortLinksLoading() => const Center(
            child: CircularProgressIndicator(key: AppKeys.shortLinksLoading),
          ),
          ShortLinksError(:final failure) => ErrorView(
            key: AppKeys.shortLinksError,
            message: failure.message,
            onRetry: () =>
                context.read<ShortLinksBloc>().add(const ShortLinksRetried()),
          ),
          ShortLinksEmpty(:final actionFailure) => _list(
            context,
            [
              const Text(
                'No links yet. Paste a URL above.',
                key: AppKeys.shortLinksEmpty,
              ),
            ],
            actionFailure,
            false,
          ),
          ShortLinksData(
            :final items,
            :final nextCursor,
            :final isLoadingMore,
            :final isCreating,
            :final actionFailure,
          ) =>
            _list(
              context,
              [
                for (final link in items)
                  ShortLinkTile(link: link, opener: widget.urlOpener),
                if (nextCursor != null)
                  AppButton(
                    key: AppKeys.shortLinksLoadMore,
                    label: isLoadingMore ? 'Loading...' : 'Load more',
                    onPressed: isLoadingMore
                        ? null
                        : () => context.read<ShortLinksBloc>().add(
                            const ShortLinksMoreRequested(),
                          ),
                  ),
              ],
              actionFailure,
              isCreating,
            ),
        };
      },
    );
  }

  Widget _list(
    BuildContext context,
    List<Widget> rows,
    Failure? failure,
    bool creating,
  ) {
    return ListView(
      key: AppKeys.shortLinksList,
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TextField(
          key: AppKeys.urlField,
          controller: _url,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Long URL',
            hintText: 'Paste a long URL',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          key: AppKeys.aliasField,
          controller: _alias,
          decoration: const InputDecoration(
            labelText: 'Custom alias (optional)',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: AppKeys.shortenButton,
          label: creating ? 'Shortening...' : 'Shorten',
          onPressed: creating ? null : () => _submit(context),
        ),
        if (failure != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              failure.message,
              key: AppKeys.actionError,
              style: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (_latest != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            key: AppKeys.latestResult,
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _latest!.shortUrl,
                    style: AppTypography.title,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: _latest!.shortUrl)),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        for (final w in rows) ...[w, const SizedBox(height: AppSpacing.sm)],
      ],
    );
  }
}
