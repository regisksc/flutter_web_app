import 'package:flutter/material.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_radii.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_spacing.dart';

/// Surface container with optional tap handling.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap});

  /// Content of the card.
  final Widget child;

  /// Tap callback, or null for a non-interactive card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
      child: InkWell(
        borderRadius: AppRadii.borderMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}
