import 'package:flutter_web_app/features/short_links/data/models/short_link_model.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link_page.dart';

/// JSON shape of one page: items plus next_cursor.
class ShortLinkPageModel {
  const ShortLinkPageModel({required this.items, this.nextCursor});

  factory ShortLinkPageModel.fromJson(Map<String, dynamic> json) =>
      ShortLinkPageModel(
        items: (json['items'] as List<dynamic>)
            .map(
              (item) => ShortLinkModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        nextCursor: json['next_cursor'] as String?,
      );

  final List<ShortLinkModel> items;
  final String? nextCursor;

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'next_cursor': nextCursor,
  };

  ShortLinkPage toEntity() => ShortLinkPage(
    items: items.map((item) => item.toEntity()).toList(),
    nextCursor: nextCursor,
  );
}
