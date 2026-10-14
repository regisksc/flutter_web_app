import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/create_short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/list_short_links.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/resolve_short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_state.dart';

/// Drives the short links screen: list, paging, create and open.
class ShortLinksBloc extends Bloc<ShortLinksEvent, ShortLinksState> {
  ShortLinksBloc({
    required ListShortLinks listShortLinks,
    required CreateShortLink createShortLink,
    required ResolveShortLink resolveShortLink,
  }) : _list = listShortLinks,
       _create = createShortLink,
       _resolve = resolveShortLink,
       super(const ShortLinksLoading()) {
    on<ShortLinksStarted>(_onFirstPage);
    on<ShortLinksRetried>(_onFirstPage);
    on<ShortLinksMoreRequested>(_onMore);
    on<ShortLinkSubmitted>(_onCreate);
    on<ShortLinkOpened>(_onOpen);
  }

  /// Links per request.
  static const pageSize = 10;

  final ListShortLinks _list;
  final CreateShortLink _create;
  final ResolveShortLink _resolve;

  Future<void> _onFirstPage(
    ShortLinksEvent event,
    Emitter<ShortLinksState> emit,
  ) async {
    emit(const ShortLinksLoading());
    final result = await _list(limit: pageSize);
    emit(
      result.when<ShortLinksState>(
        ok: (page) => page.items.isEmpty
            ? const ShortLinksEmpty()
            : ShortLinksData(items: page.items, nextCursor: page.nextCursor),
        err: (failure) => ShortLinksError(failure),
      ),
    );
  }

  Future<void> _onMore(
    ShortLinksMoreRequested event,
    Emitter<ShortLinksState> emit,
  ) async {
    final current = state;
    if (current is! ShortLinksData ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return;
    }
    emit(
      ShortLinksData(
        items: current.items,
        nextCursor: current.nextCursor,
        isLoadingMore: true,
      ),
    );
    final result = await _list(cursor: current.nextCursor, limit: pageSize);
    emit(
      result.when<ShortLinksState>(
        ok: (page) => ShortLinksData(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
        err: (failure) => ShortLinksData(
          items: current.items,
          nextCursor: current.nextCursor,
          actionFailure: failure,
        ),
      ),
    );
  }

  /// Creates a link. Empty list has no creating flag, so the form only shows the result.
  Future<void> _onCreate(
    ShortLinkSubmitted event,
    Emitter<ShortLinksState> emit,
  ) async {
    final current = state;
    if (current is ShortLinksData) {
      emit(
        ShortLinksData(
          items: current.items,
          nextCursor: current.nextCursor,
          isLoadingMore: current.isLoadingMore,
          isCreating: true,
        ),
      );
    } else if (current is! ShortLinksEmpty) {
      return;
    }
    final result = await _create(longUrl: event.longUrl, alias: event.alias);
    emit(
      result.when<ShortLinksState>(
        ok: (link) => current is ShortLinksData
            ? ShortLinksData(
                items: [link, ...current.items],
                nextCursor: current.nextCursor,
              )
            : ShortLinksData(items: [link]),
        err: (failure) => current is ShortLinksData
            ? ShortLinksData(
                items: current.items,
                nextCursor: current.nextCursor,
                actionFailure: failure,
              )
            : ShortLinksEmpty(actionFailure: failure),
      ),
    );
  }

  /// Opens a link and replaces it in the list with its new click count.
  Future<void> _onOpen(
    ShortLinkOpened event,
    Emitter<ShortLinksState> emit,
  ) async {
    final current = state;
    if (current is! ShortLinksData) return;
    final result = await _resolve(event.code);
    emit(
      result.when<ShortLinksState>(
        ok: (link) => ShortLinksData(
          items: [
            for (final item in current.items)
              item.code == link.code ? link : item,
          ],
          nextCursor: current.nextCursor,
          isLoadingMore: current.isLoadingMore,
        ),
        err: (failure) => ShortLinksData(
          items: current.items,
          nextCursor: current.nextCursor,
          actionFailure: failure,
        ),
      ),
    );
  }
}
