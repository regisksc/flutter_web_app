# lib: rules

- Layers per feature: domain (pure Dart) <- data <- presentation. Presentation depends on use cases only.
- Domain imports nothing from data or presentation or Flutter.
- Data returns Failure values inside Result. Exceptions stop at the data source.
- Exceptions never cross a repository boundary. Repository converts NetworkException, ServerException, others into Failure or UnexpectedFailure.
- Presentation never imports data. Bloc calls use cases only.
- Code comments: explain why, name the gotcha. Skip the obvious. "// ponytail:" marks shortcuts; add a SHORTCUTS.md row.
- Names follow CONTEXT.md. Use the same term in code, tests, and talk.
- Hot-reload safe by default: no globals or const changes without a queued hot restart.
- Lint: flutter analyze must print "No issues found!".
- Coverage: >=80% per changed file (tool/coverage_check.sh).
