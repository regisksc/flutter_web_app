import 'package:equatable/equatable.dart';

/// Inputs to ShortLinksBloc.
sealed class ShortLinksEvent extends Equatable {
  const ShortLinksEvent();

  @override
  List<Object?> get props => const [];
}

/// Screen opened: load the first page.
final class ShortLinksStarted extends ShortLinksEvent {
  const ShortLinksStarted();
}

/// User reached the end of the list: load the next page.
final class ShortLinksMoreRequested extends ShortLinksEvent {
  const ShortLinksMoreRequested();
}

/// User tapped retry after a failed first page.
final class ShortLinksRetried extends ShortLinksEvent {
  const ShortLinksRetried();
}

/// User tapped Shorten. [alias] is null when the field is empty.
final class ShortLinkSubmitted extends ShortLinksEvent {
  const ShortLinkSubmitted({required this.longUrl, this.alias});

  final String longUrl;
  final String? alias;

  @override
  List<Object?> get props => [longUrl, alias];
}

/// User opened a link; counts one click.
final class ShortLinkOpened extends ShortLinksEvent {
  const ShortLinkOpened(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}
