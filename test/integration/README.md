# Integration Tests

This directory is reserved for integration tests that verify how different parts of the application work together.

## What are Integration Tests?

Integration tests verify that multiple units work together correctly. They test the interaction between components, such as:
- Service + Repository integration
- UI widget + Service integration
- Multiple services working together
- Database operations with actual Firebase (using Firebase Emulator)

## Examples

- Testing that `AuthService` correctly calls `AuthRepository` and `UserRepository` in sequence
- Testing that a widget properly interacts with a service and updates its state
- Testing Firebase CRUD operations with the emulator

## Running Integration Tests

```bash
flutter test test/integration
```

## Best Practices

- Use Firebase Emulator for database tests
- Mock external APIs (TMDB) but test real Firebase integration
- Test realistic user flows across multiple components
- Keep integration tests focused on component interactions
