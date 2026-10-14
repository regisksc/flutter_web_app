import 'package:flutter/material.dart';
import 'package:flutter_web_app/core/design_system/components/app_card.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_spacing.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_typography.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';

/// One article row in the list.
class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.article});

  /// Article to show.
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        key: AppKeys.articleTile(article.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(article.title, style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            Text(article.summary, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}
