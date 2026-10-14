# lib/core: rules

- Shared only. Nothing in core imports lib/features/**.
- error/: Failure (sealed) and Result. Values, not exceptions. Add a Failure subtype only when a feature needs it.
- flags/: enum Flag, interface FeatureFlags, const FakeFeatureFlags. Add a Flag value, then gate in lib/app/app.dart.
- testing/keys.dart: AppKeys string constants for finders. Add a key here before using it in a test.
- design_system/ has its own AGENTS.md. Read it before editing there.
- Every new public type needs a unit test under test/core/.
