import 'package:flutter/material.dart';
import 'package:flutter_web_app/core/design_system/components/app_button.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_spacing.dart';
import 'package:flutter_web_app/core/testing/keys.dart';

/// Error message with a retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  /// Error text to display.
  final String message;

  /// Called when the user taps retry.
  final VoidCallback onRetry;

  /// Label of the retry button.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: AppKeys.retryButton,
              label: retryLabel,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
