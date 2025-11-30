# Integration Tests

This directory contains integration tests that verify how different parts of the application work together.

## What are Integration Tests?

Integration tests verify that multiple units work together correctly. They test the interaction between components, such as:
- Model interactions (User + Movie + Wishlist)
- Serialization and deserialization across models
- Complex workflows involving multiple models
- Data integrity across model operations

## Current Integration Tests

### Model Integration Tests (6 tests)
- `model_integration_test.dart`
  - User movie collection management
  - Wishlist and movie collection independence
  - Movie-User ownership relationship
  - Wishlist priority filtering
  - User profile update data preservation
  - Complete collection/wishlist workflow

### Serialization Integration Tests (6 tests)
- `serialization_integration_test.dart`
  - Movie round-trip serialization
  - User with nested models serialization
  - Wishlist complex items serialization
  - Enum serialization across models
  - DateTime timestamp preservation
  - Empty collection handling

## Running Integration Tests

```bash
flutter test test/integration
```

Run with detailed output:
```bash
flutter test test/integration --reporter expanded
```

## Best Practices

- Test real interactions between models
- Verify data integrity across operations
- Test both simple and complex workflows
- Ensure serialization preserves all data
- Test edge cases (empty collections, null values)

## Test Results

**Total: 12 Integration Tests (All Passing)**
