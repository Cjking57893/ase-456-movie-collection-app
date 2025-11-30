import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

void main() {
  group('User Model', () {
    late User testUser;
    late DateTime testDate;
    late Wishlist testWishlist;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testWishlist = Wishlist(
        id: 'wishlist-123',
        createdAt: testDate,
        updatedAt: testDate,
        items: const [],
      );
      testUser = User(
        id: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: testDate,
        updatedAt: testDate,
        movieIds: const ['movie1', 'movie2'],
        wishlist: testWishlist,
      );
    });

    test('creates User with all properties', () {
      expect(testUser.id, 'user-123');
      expect(testUser.email, 'test@example.com');
      expect(testUser.displayName, 'Test User');
      expect(testUser.photoUrl, 'https://example.com/photo.jpg');
      expect(testUser.movieIds, ['movie1', 'movie2']);
      expect(testUser.movieCount, 2);
    });

    test('toMap converts User to Map correctly', () {
      final map = testUser.toMap();

      expect(map['id'], 'user-123');
      expect(map['email'], 'test@example.com');
      expect(map['displayName'], 'Test User');
      expect(map['movieIds'], ['movie1', 'movie2']);
      expect(map['wishlist'], isNotNull);
    });

    test('fromMap creates User from Map correctly', () {
      final map = testUser.toMap();
      final userFromMap = User.fromMap(map);

      expect(userFromMap.id, testUser.id);
      expect(userFromMap.email, testUser.email);
      expect(userFromMap.displayName, testUser.displayName);
      expect(userFromMap.movieIds, testUser.movieIds);
    });

    test('fromMap creates default wishlist if missing', () {
      final map = {
        'id': 'user-123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
        'movieIds': [],
      };

      final user = User.fromMap(map);

      expect(user.wishlist, isNotNull);
      expect(user.wishlist.id, 'wishlist_user-123');
    });

    test('addMovie adds movie ID to list', () {
      final updatedUser = testUser.addMovie('movie3');

      expect(updatedUser.movieIds, ['movie1', 'movie2', 'movie3']);
      expect(updatedUser.movieCount, 3);
    });

    test('addMovie does not add duplicate movie ID', () {
      final updatedUser = testUser.addMovie('movie1');

      expect(updatedUser.movieIds, ['movie1', 'movie2']);
      expect(updatedUser.movieCount, 2);
    });

    test('removeMovie removes movie ID from list', () {
      final updatedUser = testUser.removeMovie('movie1');

      expect(updatedUser.movieIds, ['movie2']);
      expect(updatedUser.movieCount, 1);
    });

    test('hasMovie returns true for existing movie', () {
      expect(testUser.hasMovie('movie1'), true);
      expect(testUser.hasMovie('movie2'), true);
    });

    test('hasMovie returns false for non-existing movie', () {
      expect(testUser.hasMovie('movie99'), false);
    });

    test('addToWishlist adds item to wishlist', () {
      final item = WishlistItem(
        id: 'item1',
        movieTitle: 'Inception',
        priority: WishlistPriority.high,
        dateAdded: testDate,
      );

      final updatedUser = testUser.addToWishlist(item);

      expect(updatedUser.wishlist.items.length, 1);
      expect(updatedUser.wishlist.items.first.movieTitle, 'Inception');
      expect(updatedUser.wishlistCount, 1);
    });

    test('removeFromWishlist removes item from wishlist', () {
      final item = WishlistItem(
        id: 'item1',
        movieTitle: 'Inception',
        dateAdded: testDate,
      );
      final userWithWishlist = testUser.addToWishlist(item);
      final updatedUser = userWithWishlist.removeFromWishlist('item1');

      expect(updatedUser.wishlist.items.length, 0);
      expect(updatedUser.wishlistCount, 0);
    });

    test('copyWith creates new User with updated values', () {
      final updatedUser = testUser.copyWith(
        displayName: 'New Name',
        email: 'new@example.com',
      );

      expect(updatedUser.displayName, 'New Name');
      expect(updatedUser.email, 'new@example.com');
      expect(updatedUser.id, testUser.id); // Unchanged
    });

    test('toString returns formatted string', () {
      final result = testUser.toString();
      expect(result, 'Test User (test@example.com)');
    });

    test('movieCount returns correct count', () {
      expect(testUser.movieCount, 2);

      final emptyUser = testUser.copyWith(movieIds: []);
      expect(emptyUser.movieCount, 0);
    });
  });
}
