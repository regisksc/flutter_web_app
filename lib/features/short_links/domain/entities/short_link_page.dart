import 'package:equatable/equatable.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';

/// One page of short links plus the cursor for the next page, if any.
class ShortLinkPage extends Equatable {
  const ShortLinkPage({required this.items, this.nextCursor});

  /// Links on this page, newest first.
  final List<ShortLink> items;

  /// Cursor for the next page; null when this is the last page.
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}
