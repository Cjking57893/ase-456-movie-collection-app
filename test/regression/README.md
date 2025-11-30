# Regression Tests

This directory contains regression tests that ensure previously fixed bugs don't reappear.

## What are Regression Tests?

Regression tests are specific tests written to verify that bugs that were fixed in the past don't come back in future code changes. Each test should:
- Reference the bug/issue it addresses
- Test the specific scenario that caused the bug
- Verify the fix remains in place

## Current Regression Tests

### AuthResult Pattern Matching (7 tests)
- Tests for sealed class `AuthResult` pattern matching functionality
- Ensures `AuthSuccess` and `AuthFailure` work correctly with Dart 3 pattern matching
- Verifies all `AuthErrorType` enum values are present

### Movie Model Immutability (6 tests)
- Tests for `Movie` model immutability and data integrity
- Verifies `copyWith` creates new instances without mutating originals
- Tests serialization roundtrip (toMap/fromMap)
- Validates enum values (`MovieFormat`, `StorageLocation`)
- Ensures nullable fields are handled correctly

## Running Regression Tests

```bash
flutter test test/regression
```

Run with detailed output:
```bash
flutter test test/regression --reporter expanded
```

## Best Practices

- Include bug/issue number in test name or comments
- Document what the original bug was
- Keep tests even if they seem redundant with other tests
- Add a new regression test for each significant bug fix

## Test Results

**Total: 13 Regression Tests (All Passing)**
