# Test Organization

This directory contains the test suite for the Movie Collection App, organized by test type.

## Directory Structure

```
test/
├── unit/                   # Unit tests (isolated component testing)
│   ├── models/            # Model class tests
│   ├── services/          # Service layer tests
│   ├── repositories/      # Repository tests
│   ├── utils/             # Utility function tests
│   └── core/              # Core functionality tests
├── integration/           # Integration tests (component interaction)
├── regression/            # Regression tests (prevent bugs from returning)
└── acceptance/            # Acceptance tests (user scenarios)
```

## Unit Tests

Unit tests verify individual components in isolation. They use mocks for dependencies.

### Running Unit Tests

```bash
# Run all unit tests
flutter test test/unit

# Run specific test file
flutter test test/unit/models/movie_test.dart

# Run with coverage
flutter test --coverage test/unit
```

### Generating Mocks

This project uses `mockito` for mocking dependencies. To generate mock files:

```bash
# Install dependencies first
flutter pub get

# Generate mocks for all test files with @GenerateMocks annotation
dart run build_runner build

# Or watch for changes
dart run build_runner watch
```

### Test Coverage

Current unit test coverage:
- **Models**: Movie, User, Wishlist, WishlistItem
- **Services**: AuthService, MovieService, WishlistService
- **Utils**: Validators
- **Core**: AuthResult

## Integration Tests

Integration tests verify that multiple components work together correctly.
_To be implemented_

## Regression Tests

Regression tests ensure that previously fixed bugs don't reappear.
_To be implemented_

## Acceptance Tests

Acceptance tests verify end-to-end user scenarios and workflows.
_To be implemented_

## Best Practices

1. **Test Naming**: Use descriptive names that explain what is being tested
2. **AAA Pattern**: Arrange, Act, Assert
3. **One Assertion Per Test**: Keep tests focused
4. **Mock External Dependencies**: Use mocks for Firebase, HTTP, etc.
5. **Test Edge Cases**: Include null, empty, and error cases
6. **Keep Tests Fast**: Unit tests should run quickly

## Writing New Tests

### Model Tests
```dart
group('ModelName', () {
  late ModelName model;
  
  setUp(() {
    model = ModelName(...);
  });

  test('creates model with properties', () {
    expect(model.property, expectedValue);
  });
});
```

### Service Tests with Mocks
```dart
@GenerateMocks([DependencyClass])
void main() {
  group('ServiceName', () {
    late ServiceName service;
    late MockDependencyClass mockDependency;

    setUp(() {
      mockDependency = MockDependencyClass();
      service = ServiceName(dependency: mockDependency);
    });

    test('performs action', () async {
      when(mockDependency.method()).thenAnswer((_) async => result);
      
      final result = await service.performAction();
      
      expect(result, expectedValue);
      verify(mockDependency.method()).called(1);
    });
  });
}
```

## Continuous Integration

Tests are run automatically on:
- Every commit
- Pull requests
- Before deployment

Ensure all tests pass before merging code.
