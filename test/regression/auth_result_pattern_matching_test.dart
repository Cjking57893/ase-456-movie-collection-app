import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/core/auth_result.dart';

void main() {
  group('Regression: AuthResult Pattern Matching', () {
    test('AuthSuccess can be pattern matched correctly', () {
      // Regression test for sealed class pattern matching
      // Ensures AuthSuccess and AuthFailure are properly discriminated

      final result = AuthSuccess('test-123');

      final message = switch (result) {
        AuthSuccess(userId: final id) => 'Success: $id',
        AuthFailure() => 'Failed',
      };

      expect(message, 'Success: test-123');
    });

    test('AuthFailure can be pattern matched with error type', () {
      // Test that AuthFailure pattern matching works with all error types

      final failures = [
        AuthFailure('Invalid email', AuthErrorType.invalidEmail),
        AuthFailure('Wrong password', AuthErrorType.wrongPassword),
        AuthFailure('User not found', AuthErrorType.userNotFound),
        AuthFailure('Email in use', AuthErrorType.emailAlreadyInUse),
        AuthFailure('Weak password', AuthErrorType.weakPassword),
        AuthFailure('Too many requests', AuthErrorType.tooManyRequests),
        AuthFailure('Network error', AuthErrorType.networkError),
        AuthFailure('Unknown error', AuthErrorType.unknown),
      ];

      for (final failure in failures) {
        final message = switch (failure) {
          AuthSuccess() => 'Success',
          AuthFailure(type: AuthErrorType.invalidEmail) => 'Invalid email',
          AuthFailure(type: AuthErrorType.wrongPassword) =>
            'Wrong password',
          AuthFailure(type: AuthErrorType.userNotFound) => 'User not found',
          AuthFailure(type: AuthErrorType.emailAlreadyInUse) =>
            'Email in use',
          AuthFailure(type: AuthErrorType.weakPassword) => 'Weak password',
          AuthFailure(type: AuthErrorType.tooManyRequests) =>
            'Too many requests',
          AuthFailure(type: AuthErrorType.networkError) => 'Network error',
          AuthFailure(type: AuthErrorType.unknown) => 'Unknown error',
          AuthFailure(type: AuthErrorType.userDisabled) => 'User disabled',
        };

        expect(message, isNotEmpty);
      }
    });

    test('Pattern matching ensures exhaustiveness', () {
      // Regression test that sealed class forces exhaustive matching
      // This would fail at compile time if a case was missing

      AuthResult testBothCases(AuthResult result) {
        return switch (result) {
          AuthSuccess() => result,
          AuthFailure() => result,
          // Compiler would error if any case was missing
        };
      }

      final success = AuthSuccess('test-123');
      final failure = AuthFailure('Test', AuthErrorType.unknown);

      expect(testBothCases(success), isA<AuthSuccess>());
      expect(testBothCases(failure), isA<AuthFailure>());
    });

    test('AuthResult as sealed class prevents direct instantiation', () {
      // Regression test ensuring AuthResult cannot be instantiated directly
      // Only AuthSuccess and AuthFailure can be created

      // This is enforced at compile time by the sealed keyword
      // We test that the subtypes work correctly

      final success = AuthSuccess('user-1');
      final failure = AuthFailure('Error', AuthErrorType.unknown);

      expect(success, isA<AuthResult>());
      expect(failure, isA<AuthResult>());
      expect(success, isNot(isA<AuthFailure>()));
      expect(failure, isNot(isA<AuthSuccess>()));
    });

    test('AuthSuccess userId is accessible', () {
      // Regression test for AuthSuccess field access

      final success = AuthSuccess('test-123');

      expect(success.userId, 'test-123');
    });

    test('AuthFailure message and type are accessible', () {
      // Regression test for AuthFailure field access

      final failure = AuthFailure('Test error', AuthErrorType.networkError);

      expect(failure.message, 'Test error');
      expect(failure.type, AuthErrorType.networkError);
    });

    test('All AuthErrorType values are unique', () {
      // Regression test ensuring enum values are distinct

      final errorTypes = AuthErrorType.values;

      expect(errorTypes.length, 9);
      expect(errorTypes.toSet().length, 9); // All unique

      expect(errorTypes, contains(AuthErrorType.invalidEmail));
      expect(errorTypes, contains(AuthErrorType.wrongPassword));
      expect(errorTypes, contains(AuthErrorType.userNotFound));
      expect(errorTypes, contains(AuthErrorType.emailAlreadyInUse));
      expect(errorTypes, contains(AuthErrorType.weakPassword));
      expect(errorTypes, contains(AuthErrorType.userDisabled));
      expect(errorTypes, contains(AuthErrorType.tooManyRequests));
      expect(errorTypes, contains(AuthErrorType.networkError));
      expect(errorTypes, contains(AuthErrorType.unknown));
    });
  });
}
