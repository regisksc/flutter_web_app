import 'package:flutter/painting.dart';

/// Corner radius scale.
abstract final class AppRadii {
  static const double sm = 4;
  static const double md = 12;
  static const double lg = 20;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
}
