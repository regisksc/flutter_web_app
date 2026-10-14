/// Feature toggles known to the app.
enum Flag { articleList, shortLinks }

/// Read-only access to feature toggles.
abstract interface class FeatureFlags {
  /// Whether [flag] is switched on.
  bool isEnabled(Flag flag);
}

/// In-memory flags for local runs and tests.
final class FakeFeatureFlags implements FeatureFlags {
  const FakeFeatureFlags({this.enabled = const {Flag.articleList}});

  /// Flags that are on.
  final Set<Flag> enabled;

  @override
  bool isEnabled(Flag flag) => enabled.contains(flag);
}
