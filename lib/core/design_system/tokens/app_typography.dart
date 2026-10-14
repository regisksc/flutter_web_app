import 'package:flutter/painting.dart';

/// Text styles; uses the platform default font.
abstract final class AppTypography {
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(fontSize: 14, height: 1.4);
  static const TextStyle caption = TextStyle(fontSize: 12);
}
