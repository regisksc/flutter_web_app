import 'package:flutter/material.dart';

/// Primary action button; a null [onPressed] renders it disabled.
class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed});

  /// Text shown on the button.
  final String label;

  /// Tap callback, or null to disable.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: onPressed, child: Text(label));
  }
}
