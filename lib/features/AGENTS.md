# lib/features: rules

- Feature-first: one folder per feature with domain/, data/, presentation/.
- Features do not import other features. Share through lib/core only.
- Start a feature with tool/new_feature.sh <name>, then follow docs/NEW_FEATURE.md.
- A feature needs a spec in docs/specs/<name>.md before code (grill, then spec).
- Gate new user-visible behavior behind a Flag unless the spec says otherwise.
- Every feature ships: unit, bloc_test, widget tests per state, one golden, mirrored test folders.
