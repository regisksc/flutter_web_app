import 'package:equatable/equatable.dart';

/// Article summary shown in the list.
class Article extends Equatable {
  const Article({required this.id, required this.title, required this.summary});

  /// Stable identifier.
  final String id;

  /// Headline text.
  final String title;

  /// Short description.
  final String summary;

  @override
  List<Object?> get props => [id, title, summary];
}
