# presentation: short_links

- bloc/: sealed states loading, data, empty, error. Calls use cases only.
- view/: render state, dispatch events. Design-system components only. AppKeys for finders.
- widgets/: small stateless pieces.
- No imports from data/.
