# lib/core/design_system: rules

- tokens/ holds colors, spacing, type. Components use tokens only; no hard-coded colors or sizes in features.
- components/: AppButton, AppCard, ErrorView. Stateless. No business logic, no feature imports.
- Each component: widget test for states; include AppKeys where tests need a finder.
- Changing a token changes goldens. Re-run goldens; never update them without human approval.
- Keep components small. Add a new component only when two features need it.
