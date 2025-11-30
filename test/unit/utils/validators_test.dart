import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/utils/validators.dart';
import 'package:movie_collection_app/core/constants.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.co.uk'), isNull);
        expect(Validators.email('test123@test-domain.com'), isNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@example.com'), isNotNull);
        expect(Validators.email('test@domain'), isNotNull);
        expect(Validators.email('test domain@example.com'), isNotNull);
      });

      test('returns error for null or empty email', () {
        expect(Validators.email(null), 'Enter your email');
        expect(Validators.email(''), 'Enter your email');
      });
    });

    group('password', () {
      test('returns null for valid password', () {
        expect(Validators.password('password123'), isNull);
        expect(Validators.password('MyP@ssw0rd'), isNull);
        expect(Validators.password('123456'), isNull);
      });

      test('returns error for password too short', () {
        expect(
          Validators.password('12345'),
          'Password must be at least ${AppConstants.minPasswordLength} characters',
        );
        expect(
          Validators.password('abc'),
          'Password must be at least ${AppConstants.minPasswordLength} characters',
        );
      });

      test('returns error for null or empty password', () {
        expect(Validators.password(null), 'Enter a password');
        expect(Validators.password(''), 'Enter a password');
      });
    });

    group('confirmPassword', () {
      test('returns null when passwords match', () {
        expect(Validators.confirmPassword('password', 'password'), isNull);
        expect(Validators.confirmPassword('Test123!', 'Test123!'), isNull);
      });

      test('returns error when passwords do not match', () {
        expect(
          Validators.confirmPassword('password1', 'password2'),
          'Passwords do not match',
        );
        expect(
          Validators.confirmPassword('Test123!', 'test123!'),
          'Passwords do not match',
        );
      });

      test('returns error for null or empty confirm password', () {
        expect(Validators.confirmPassword(null, 'password'), 'Confirm your password');
        expect(Validators.confirmPassword('', 'password'), 'Confirm your password');
      });
    });

    group('displayName', () {
      test('returns null for valid name', () {
        expect(Validators.displayName('John Doe'), isNull);
        expect(Validators.displayName('Alice'), isNull);
        expect(Validators.displayName('A B'), isNull);
      });

      test('returns error for name too short', () {
        expect(
          Validators.displayName(' '),
          'Enter your name',
        );
      });

      test('returns error for null or empty name', () {
        expect(Validators.displayName(null), 'Enter your name');
        expect(Validators.displayName(''), 'Enter your name');
        expect(Validators.displayName('   '), 'Enter your name');
      });
    });

    group('required', () {
      test('returns null for non-empty value', () {
        expect(Validators.required('value'), isNull);
        expect(Validators.required('test', 'Field'), isNull);
      });

      test('returns error for null or empty value', () {
        expect(Validators.required(null), 'This field is required');
        expect(Validators.required(''), 'This field is required');
        expect(Validators.required('   '), 'This field is required');
      });

      test('uses custom field name in error message', () {
        expect(Validators.required(null, 'Movie title'), 'Movie title is required');
        expect(Validators.required('', 'Email'), 'Email is required');
      });
    });
  });
}
