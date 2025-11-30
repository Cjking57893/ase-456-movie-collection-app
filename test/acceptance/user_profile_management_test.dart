import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/core/auth_result.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

/// Acceptance Test: User Profile Management
/// 
/// Business Requirements Verified:
/// - New users are created with all required profile information
/// - User profiles include email, display name, and timestamps
/// - Each user has an associated wishlist
/// - User profiles can be updated while preserving data integrity
/// - Authentication results properly indicate success or failure
void main() {
  group('Acceptance: User Profile Management', () {
    test('New user profile is created with required fields', () {
      // GIVEN: Registration data for a new user
      const userId = 'user_123';
      const email = 'newuser@example.com';
      const displayName = 'John Doe';
      final now = DateTime.now();

      // WHEN: Creating a new user profile
      final user = User(
        id: userId,
        email: email,
        displayName: displayName,
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(
          id: 'wishlist_$userId',
          createdAt: now,
          updatedAt: now,
          items: [],
        ),
      );

      // THEN: User profile has all required information
      expect(user.id, userId);
      expect(user.email, email);
      expect(user.displayName, displayName);
      expect(user.createdAt, now);
      expect(user.updatedAt, now);
      
      // AND: User starts with empty collection
      expect(user.movieIds, isEmpty);
      expect(user.movieCount, 0);
      
      // AND: User has associated wishlist
      expect(user.wishlist.items, isEmpty);
      expect(user.wishlist.itemCount, 0);
    });

    test('User profile can be serialized and deserialized', () {
      // GIVEN: A complete user profile
      final now = DateTime.now();
      final user = User(
        id: 'user_456',
        email: 'serialize@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        updatedAt: now,
        movieIds: ['movie_1', 'movie_2'],
        wishlist: Wishlist(
          id: 'wishlist_456',
          createdAt: now,
          updatedAt: now,
          items: [
            WishlistItem(
              id: 'item_1',
              movieTitle: 'The Matrix',
              priority: WishlistPriority.high,
              dateAdded: now,
            ),
          ],
        ),
      );

      // WHEN: Serializing to Map
      final map = user.toMap();

      // THEN: Map contains all user data
      expect(map['id'], user.id);
      expect(map['email'], user.email);
      expect(map['displayName'], user.displayName);
      expect(map['photoUrl'], user.photoUrl);
      expect(map['movieIds'], user.movieIds);
      expect(map['wishlist'], isNotNull);

      // WHEN: Deserializing back to User
      final deserialized = User.fromMap(map);

      // THEN: User is reconstructed correctly
      expect(deserialized.id, user.id);
      expect(deserialized.email, user.email);
      expect(deserialized.displayName, user.displayName);
      expect(deserialized.photoUrl, user.photoUrl);
      expect(deserialized.movieIds, user.movieIds);
      expect(deserialized.wishlist.items.length, user.wishlist.items.length);
    });

    test('User profile updates preserve identity', () {
      // GIVEN: An existing user
      final now = DateTime.now();
      final original = User(
        id: 'user_789',
        email: 'original@example.com',
        displayName: 'Original Name',
        createdAt: now,
        updatedAt: now,
        movieIds: ['movie_1'],
        wishlist: Wishlist(
          id: 'wishlist_789',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // WHEN: Updating display name
      final updated = original.copyWith(
        displayName: 'Updated Name',
        updatedAt: DateTime.now(),
      );

      // THEN: Identity fields are preserved
      expect(updated.id, original.id);
      expect(updated.email, original.email);
      expect(updated.createdAt, original.createdAt);
      
      // AND: Update is applied
      expect(updated.displayName, 'Updated Name');
      expect(updated.displayName, isNot(original.displayName));
      
      // AND: Collections are preserved
      expect(updated.movieIds, original.movieIds);
      expect(updated.wishlist.id, original.wishlist.id);
    });

    test('AuthSuccess indicates successful authentication', () {
      // GIVEN: A successful authentication
      const userId = 'authenticated_user';
      
      // WHEN: Creating AuthSuccess result
      final result = AuthSuccess(userId);
      
      // THEN: Result is AuthSuccess type
      expect(result, isA<AuthSuccess>());
      expect(result, isA<AuthResult>());
      expect(result.userId, userId);
      
      // AND: Can be pattern matched
      final message = switch (result) {
        AuthSuccess(userId: final id) => 'Success: $id',
        AuthFailure() => 'Failed',
      };
      expect(message, 'Success: $userId');
    });

    test('AuthFailure indicates authentication error', () {
      // GIVEN: An authentication failure
      const errorMsg = 'Invalid credentials';
      const errorType = AuthErrorType.wrongPassword;
      
      // WHEN: Creating AuthFailure result
      final result = AuthFailure(errorMsg, errorType);
      
      // THEN: Result is AuthFailure type
      expect(result, isA<AuthFailure>());
      expect(result, isA<AuthResult>());
      expect(result.message, errorMsg);
      expect(result.type, errorType);
      
      // AND: Can be pattern matched
      final message = switch (result) {
        AuthSuccess() => 'Success',
        AuthFailure(message: final msg, type: final type) => 'Error: $msg (${type.name})',
      };
      expect(message, 'Error: $errorMsg (wrongPassword)');
    });

    test('All authentication error types are available', () {
      // GIVEN: All possible authentication error scenarios
      final errors = [
        AuthErrorType.weakPassword,
        AuthErrorType.emailAlreadyInUse,
        AuthErrorType.userNotFound,
        AuthErrorType.wrongPassword,
        AuthErrorType.invalidEmail,
        AuthErrorType.userDisabled,
        AuthErrorType.tooManyRequests,
        AuthErrorType.networkError,
        AuthErrorType.unknown,
      ];

      // THEN: All error types exist
      expect(errors.length, 9);
      
      // AND: Can create AuthFailure for each type
      for (final errorType in errors) {
        final failure = AuthFailure('Error message', errorType);
        expect(failure.type, errorType);
      }
    });

    test('Complete user lifecycle from creation to deletion', () {
      // GIVEN: A new user is registered
      final now = DateTime.now();
      var user = User(
        id: 'lifecycle_user',
        email: 'lifecycle@example.com',
        displayName: 'Lifecycle Test',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(
          id: 'wishlist_lifecycle',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // THEN: Initial state is correct
      expect(user.movieCount, 0);
      expect(user.wishlist.itemCount, 0);

      // WHEN: User adds movies to collection
      user = user.addMovie('movie_1');
      user = user.addMovie('movie_2');
      user = user.addMovie('movie_3');

      // THEN: Collection grows
      expect(user.movieCount, 3);
      expect(user.hasMovie('movie_2'), true);

      // WHEN: User adds items to wishlist
      user = user.addToWishlist(WishlistItem(
        id: 'wish_1',
        movieTitle: 'Future Movie',
        priority: WishlistPriority.high,
        dateAdded: DateTime.now(),
      ));

      // THEN: Wishlist grows independently
      expect(user.wishlist.itemCount, 1);
      expect(user.movieCount, 3); // Collection unchanged

      // WHEN: User updates profile
      user = user.copyWith(displayName: 'Updated Lifecycle');

      // THEN: Profile updates but collections remain
      expect(user.displayName, 'Updated Lifecycle');
      expect(user.movieCount, 3);
      expect(user.wishlist.itemCount, 1);

      // WHEN: User removes a movie
      user = user.removeMovie('movie_2');

      // THEN: Collection decreases
      expect(user.movieCount, 2);
      expect(user.hasMovie('movie_2'), false);
    });
  });
}
