# Regression Tests

This directory is reserved for regression tests that ensure previously fixed bugs don't reappear.

## What are Regression Tests?

Regression tests are specific tests written to verify that bugs that were fixed in the past don't come back in future code changes. Each test should:
- Reference the bug/issue it addresses
- Test the specific scenario that caused the bug
- Verify the fix remains in place

## Examples

- Test for the ScaffoldMessenger timing bug (showing snackbar after navigation)
- Test for the Firebase index error handling bug
- Test for authentication state persistence issues

## Running Regression Tests

```bash
flutter test test/regression
```

## Best Practices

- Include bug/issue number in test name or comments
- Document what the original bug was
- Keep tests even if they seem redundant with other tests
- Add a new regression test for each significant bug fix
