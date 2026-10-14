import 'package:equatable/equatable.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';

/// Screen states of the short links list.
sealed class ShortLinksState extends Equatable {
  const ShortLinksState();

  @override
  List<Object?> get props => const [];
}

/// First page is loading.
final class ShortLinksLoading extends ShortLinksState {
  const ShortLinksLoading();
}

/// Links are shown. [actionFailure] keeps the list visible when a create, open or load-more fails.
final class ShortLinksData extends ShortLinksState {
  const ShortLinksData({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
    this.isCreating = false,
    this.actionFailure,
  });

  final List<ShortLink> items;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool isCreating;
  final Failure? actionFailure;

  @override
  List<Object?> get props => [
    items,
    nextCursor,
    isLoadingMore,
    isCreating,
    actionFailure,
  ];
}

/// No links yet; the form stays visible. [actionFailure] shows a failed create.
final class ShortLinksEmpty extends ShortLinksState {
  const ShortLinksEmpty({this.actionFailure});

  final Failure? actionFailure;

  @override
  List<Object?> get props => [actionFailure];
}

/// The first page failed to load.
final class ShortLinksError extends ShortLinksState {
  const ShortLinksError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
