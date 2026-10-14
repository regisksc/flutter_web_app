# domain: __feature__

- Pure Dart. Imports dart:core and lib/core/error only.
- Domain imports nothing from data or presentation.
- entities/: pure objects. repositories/: interfaces returning Result. usecases/: one repository call each.
- No try/catch in use cases. Results pass through.
