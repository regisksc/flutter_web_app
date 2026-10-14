# test: rules

- Mirror lib/: test/domain, test/data, test/presentation, test/core, test/app.
- Pyramid: unit, bloc_test, widget, golden. Integration lives in integration_test/.
- Goldens sit in goldens/ next to the golden test. Ahem font. Never update without human approval (flutter test --update-goldens).
- Tests are the contract. Never edit an assertion to pass. Fix the code or ask.
- Use mocktail for mocks. Use bloc_test for Bloc transitions.
- New behavior: write the test first and see it fail for the right reason (not a compile error).
- Run: flutter test --coverage; tool/coverage_check.sh.
