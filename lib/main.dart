import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_app/app/app.dart';
import 'package:flutter_web_app/app/bootstrap.dart';
import 'package:flutter_web_app/core/flags/feature_flags.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  // Debug builds only: lets the Marionette MCP drive the running app. Release builds skip it.
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(
    App(
      dependencies: AppDependencies.create(
        flags: const FakeFeatureFlags(enabled: {Flag.shortLinks}),
      ),
    ),
  );
}
