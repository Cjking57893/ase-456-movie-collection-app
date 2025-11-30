# Acceptance Tests

This directory is reserved for acceptance tests that verify end-to-end user scenarios.

## What are Acceptance Tests?

Acceptance tests (also called E2E tests) verify complete user workflows from start to finish. They test the application as a whole, simulating real user interactions:
- Complete user journeys
- Cross-screen workflows
- Real backend integration
- UI interactions and navigation

## Examples

- User signs up, logs in, adds a movie, edits it, and deletes it
- User searches for a movie on TMDB and adds it to their collection
- User adds a movie to wishlist, then moves it to collection
- User resets password and logs in with new password

## Running Acceptance Tests

```bash
flutter test test/acceptance
```

Or use integration_test for real device/emulator testing:

```bash
flutter test integration_test
```

## Best Practices

- Test complete user workflows, not individual features
- Use descriptive test names that match user stories
- Consider using `integration_test` package for driver tests
- May require Firebase Emulator or test account
- Test happy paths and critical error scenarios
