# ShortLinks feature: rules

- Layers: domain (pure Dart) <- data <- presentation.
- Presentation depends on use cases only. Never import data/.
- Data returns Failure inside Result. Exceptions stop at the data source.
- Keep names in CONTEXT.md terms. Add new terms there first.
