# Optional tools

## repowise (not installed, untested here)

- What: codebase-intelligence MCP server. Source: github.com/repowise-dev/repowise
- License: AGPL-3.0. Check it fits your use before installing.
- Status: NOT installed in this kit. Not tested here.

## Marionette (installed and verified 2026-10-14)

Lets an agent drive a running debug Flutter app through an MCP server.

1. Add marionette_flutter as a dev dependency. This needs a human-approved dependency change.
2. In lib/main.dart, debug only:

```dart
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  if (kDebugMode) MarionetteBinding.ensureInitialized();
  // ...existing bootstrap
}
```

3. Call tools from bash: ```mcporter --config config/mcporter.json call marionette.<tool>```
4. DSH cannot load new MCP servers without a restart. Until restart, use the bash route above.

## Patrol

E2E on device. See patrol_test/README.md. Not set up in this kit.

## Marionette verification

marionette_flutter ^0.7.0 with a kDebugMode guard in main.dart. Daemon: mcporter daemon start; connect to the ws://.../ws URI printed by flutter run; enter_text + tap by AppKeys; get_interactive_elements showed the result card (shortLinks.latestResult) and the new tile.
