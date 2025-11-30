import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/core/auth_result.dart';

void main() {
  group('AuthResult', () {
    group('AuthSuccess', () {
      test('creates AuthSuccess with userId', () {
        final success = AuthSuccess('user-123');
        
        expect(success, isA<AuthSuccess>());
        expect(success.userId, 'user-123');
      });

      test('is subtype of AuthResult', () {
        final success = AuthSuccess('user-123');
        
        expect(success, isA<AuthResult>());
      });
    });

    group('AuthFailure', () {
      test('creates AuthFailure with message and type', () {
        final failure = AuthFailure('Invalid email', AuthErrorType.invalidEmail);
        
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Invalid email');
        expect(failure.type, AuthErrorType.invalidEmail);
      });

      test('is subtype of AuthResult', () {
        final failure = AuthFailure('Error', AuthErrorType.unknown);
        
        expect(failure, isA<AuthResult>());
      });

      test('creates failure for each error type', () {
        final weakPassword = AuthFailure(
          'Password is too weak',
          AuthErrorType.weakPassword,
        );
        expect(weakPassword.type, AuthErrorType.weakPassword);

        final emailInUse = AuthFailure(
          'Email already in use',
          AuthErrorType.emailAlreadyInUse,
        );
        expect(emailInUse.type, AuthErrorType.emailAlreadyInUse);

        final userNotFound = AuthFailure(
          'User not found',
          AuthErrorType.userNotFound,
        );
        expect(userNotFound.type, AuthErrorType.userNotFound);
      });
    });

    group('AuthErrorType Enum', () {
      test('has all expected error types', () {
        expect(AuthErrorType.values.length, 9);
        expect(AuthErrorType.values.contains(AuthErrorType.weakPassword), true);
        expect(AuthErrorType.values.contains(AuthErrorType.emailAlreadyInUse), true);
        expect(AuthErrorType.values.contains(AuthErrorType.userNotFound), true);
        expect(AuthErrorType.values.contains(AuthErrorType.wrongPassword), true);
        expect(AuthErrorType.values.contains(AuthErrorType.invalidEmail), true);
        expect(AuthErrorType.values.contains(AuthErrorType.userDisabled), true);
        expect(AuthErrorType.values.contains(AuthErrorType.tooManyRequests), true);
        expect(AuthErrorType.values.contains(AuthErrorType.networkError), true);
        expect(AuthErrorType.values.contains(AuthErrorType.unknown), true);
      });
    });

    group('Pattern Matching', () {
      test('can pattern match on AuthResult', () {
        AuthResult result = AuthSuccess('user-123');
        
        switch (result) {
          case AuthSuccess(:final userId):
            expect(userId, 'user-123');
          case AuthFailure():
            fail('Should not be AuthFailure');
        }
      });

      test('can pattern match on AuthFailure', () {
        AuthResult result = AuthFailure('Error', AuthErrorType.unknown);
        
        switch (result) {
          case AuthSuccess():
            fail('Should not be AuthSuccess');
          case AuthFailure(:final message, :final type):
            expect(message, 'Error');
            expect(type, AuthErrorType.unknown);
        }
      });
    });
  });
}
