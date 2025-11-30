import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:movie_collection_app/services/auth_service.dart';
import 'package:movie_collection_app/repositories/auth_repository.dart';
import 'package:movie_collection_app/repositories/user_repository.dart';
import 'package:movie_collection_app/core/auth_result.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([UserRepository, firebase_auth.User])
@GenerateNiceMocks([MockSpec<AuthRepository>()])
void main() {
  // Provide dummy value for sealed class AuthResult
  provideDummy<AuthResult>(AuthFailure('Dummy', AuthErrorType.unknown));
  
  group('AuthService', () {
    late AuthService authService;
    late MockAuthRepository mockAuthRepository;
    late MockUserRepository mockUserRepository;
    late MockUser mockFirebaseUser;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUserRepository = MockUserRepository();
      mockFirebaseUser = MockUser();
      authService = AuthService(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
    });

    group('signIn', () {
      test('returns AuthSuccess on successful sign in', () async {
        when(mockAuthRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => AuthSuccess('user-123'));

        final result = await authService.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<AuthSuccess>());
        expect((result as AuthSuccess).userId, 'user-123');
        verify(mockAuthRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('returns AuthFailure on failed sign in', () async {
        when(mockAuthRepository.signIn(
          email: 'test@example.com',
          password: 'wrongpassword',
        )).thenAnswer((_) async => AuthFailure(
          'Wrong password',
          AuthErrorType.wrongPassword,
        ));

        final result = await authService.signIn(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        expect(result, isA<AuthFailure>());
        expect((result as AuthFailure).message, 'Wrong password');
        expect(result.type, AuthErrorType.wrongPassword);
      });
    });

    group('signUp', () {
      test('creates user profile on successful sign up', () async {
        when(mockAuthRepository.signUp(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        )).thenAnswer((_) async => AuthSuccess('user-123'));

        when(mockUserRepository.createUser(any))
            .thenAnswer((_) async => Future.value());

        final result = await authService.signUp(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        );

        expect(result, isA<AuthSuccess>());
        verify(mockAuthRepository.signUp(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        )).called(1);
        verify(mockUserRepository.createUser(any)).called(1);
      });

      test('signs out and returns failure if user creation fails', () async {
        when(mockAuthRepository.signUp(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        )).thenAnswer((_) async => AuthSuccess('user-123'));

        when(mockUserRepository.createUser(any))
            .thenThrow(Exception('Database error'));

        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => Future.value());

        final result = await authService.signUp(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        );

        expect(result, isA<AuthFailure>());
        expect((result as AuthFailure).message, 'Could not sign up');
        verify(mockAuthRepository.signOut()).called(1);
      });

      test('returns AuthFailure if sign up fails', () async {
        when(mockAuthRepository.signUp(
          email: 'existing@example.com',
          password: 'password123',
          displayName: 'User',
        )).thenAnswer((_) async => AuthFailure(
          'Email already in use',
          AuthErrorType.emailAlreadyInUse,
        ));

        final result = await authService.signUp(
          email: 'existing@example.com',
          password: 'password123',
          displayName: 'User',
        );

        expect(result, isA<AuthFailure>());
        expect((result as AuthFailure).type, AuthErrorType.emailAlreadyInUse);
        verifyNever(mockUserRepository.createUser(any));
      });
    });

    group('resetPassword', () {
      test('returns AuthSuccess on successful password reset', () async {
        when(mockAuthRepository.resetPassword('test@example.com'))
            .thenAnswer((_) async => AuthSuccess(''));

        final result = await authService.resetPassword('test@example.com');

        expect(result, isA<AuthSuccess>());
        verify(mockAuthRepository.resetPassword('test@example.com')).called(1);
      });

      test('returns AuthFailure if email not found', () async {
        when(mockAuthRepository.resetPassword('unknown@example.com'))
            .thenAnswer((_) async => AuthFailure(
          'User not found',
          AuthErrorType.userNotFound,
        ));

        final result = await authService.resetPassword('unknown@example.com');

        expect(result, isA<AuthFailure>());
        expect((result as AuthFailure).type, AuthErrorType.userNotFound);
      });
    });

    group('signOut', () {
      test('calls repository signOut', () async {
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => Future.value());

        await authService.signOut();

        verify(mockAuthRepository.signOut()).called(1);
      });
    });

    group('currentUser', () {
      test('returns current user from repository', () {
        when(mockAuthRepository.currentUser).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('user-123');

        final user = authService.currentUser;

        expect(user, isNotNull);
        expect(user!.uid, 'user-123');
      });

      test('returns null when no user signed in', () {
        when(mockAuthRepository.currentUser).thenReturn(null);

        final user = authService.currentUser;

        expect(user, isNull);
      });
    });

    group('isAuthenticated', () {
      test('returns true when user is signed in', () {
        when(mockAuthRepository.currentUser).thenReturn(mockFirebaseUser);

        expect(authService.isAuthenticated, true);
      });

      test('returns false when no user is signed in', () {
        when(mockAuthRepository.currentUser).thenReturn(null);

        expect(authService.isAuthenticated, false);
      });
    });

    group('getCurrentAppUser', () {
      test('returns user profile when authenticated', () async {
        final testDate = DateTime(2024, 1, 1);
        final testUser = User(
          id: 'user-123',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: testDate,
          updatedAt: testDate,
          wishlist: Wishlist(
            id: 'wishlist-123',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        );

        when(mockAuthRepository.currentUser).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn('user-123');
        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => testUser);

        final user = await authService.getCurrentAppUser();

        expect(user, isNotNull);
        expect(user!.id, 'user-123');
        expect(user.email, 'test@example.com');
      });

      test('returns null when not authenticated', () async {
        when(mockAuthRepository.currentUser).thenReturn(null);

        final user = await authService.getCurrentAppUser();

        expect(user, isNull);
        verifyNever(mockUserRepository.getUser(any));
      });
    });
  });
}
