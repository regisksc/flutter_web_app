import 'package:flutter_web_app/features/example/domain/entities/article.dart';

/// JSON shape of one article.
class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
    );
  }

  /// Stable identifier.
  final String id;

  /// Headline text.
  final String title;

  /// Short description.
  final String summary;

  /// JSON form, mirrors fromJson.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
  };

  /// Maps to the domain entity.
  Article toEntity() => Article(id: id, title: title, summary: summary);
}
