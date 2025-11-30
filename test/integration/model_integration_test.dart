import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';
import 'package:movie_collection_app/models/movie.dart';

void main() {
  group('Integration: User + Wishlist + Movie Interaction', () {
    test('User can add and remove movies from collection', () {
      // Integration test: User model integrates with movie IDs
      // Tests movie collection management

      final now = DateTime.now();
      final user = User(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: now,
        updatedAt: now,
        wishlist: Wishlist(
          id: 'wishlist-1',
          createdAt: now,
          updatedAt: now,
          items: const [],
        ),
      );

      // Add movies to collection
      final withMovie1 = user.addMovie('movie-1');
      final withBothMovies = withMovie1.addMovie('movie-2');

      expect(withBothMovies.movieCount, 2);
      expect(withBothMovies.hasMovie('movie-1'), isTrue);
      expect(withBothMovies.hasMovie('movie-2'), isTrue);

      // Remove a movie
      final afterRemoval = withBothMovies.removeMovie('movie-1');

      expect(afterRemoval.movieCount, 1);
      expect(afterRemoval.hasMovie('movie-1'), isFalse);
      expect(afterRemoval.hasMovie('movie-2'), isTrue);
    });

    test('User can manage wishlist items independently of movie collection', () {
      // Integration test: Wishlist and movie collection are separate
      // Tests that wishlist doesn't affect movie IDs

      final now = DateTime.now();
      final user = User(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        movieIds: const ['movie-1', 'movie-2'],
        createdAt: now,
        updatedAt: now,
        wishlist: Wishlist(
          id: 'wishlist-1',
          createdAt: now,
          updatedAt: now,
          items: const [],
        ),
      );

      final wishlistItem = WishlistItem(
        id: 'wishlist-item-1',
        movieTitle: 'Wanted Movie',
        priority: WishlistPriority.high,
        dateAdded: now,
      );

      final withWishlistItem = user.addToWishlist(wishlistItem);

      // Movie collection should remain unchanged
      expect(withWishlistItem.movieCount, 2);
      expect(withWishlistItem.hasMovie('movie-1'), isTrue);
      expect(withWishlistItem.hasMovie('movie-2'), isTrue);

      // Wishlist should have the item
      expect(withWishlistItem.wishlist.items.length, 1);
      expect(withWishlistItem.wishlist.items.first.movieTitle, 'Wanted Movie');
    });

    test('Movie model integrates with User ownership', () {
      // Integration test: Movie knows its owner
      // Tests movie-user relationship

      final now = DateTime.now();
      const userId = 'user-123';

      final movie = Movie(
        id: 'movie-1',
        userId: userId,
        title: 'Test Movie',
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.livingRoom,
        createdAt: now,
        updatedAt: now,
      );

      // Verify ownership
      expect(movie.userId, userId);

      // Movie can be serialized and deserialized maintaining userId
      final map = movie.toMap();
      final reconstructed = Movie.fromMap(map);

      expect(reconstructed.userId, userId);
    });

    test('Wishlist can filter items by priority for user planning', () {
      // Integration test: Wishlist filtering helps user prioritize
      // Tests wishlist organization

      final now = DateTime.now();
      final items = [
        WishlistItem(
          id: 'item-1',
          movieTitle: 'High Priority Movie',
          priority: WishlistPriority.high,
          dateAdded: now,
        ),
        WishlistItem(
          id: 'item-2',
          movieTitle: 'Low Priority Movie',
          priority: WishlistPriority.low,
          dateAdded: now,
        ),
        WishlistItem(
          id: 'item-3',
          movieTitle: 'Medium Priority Movie',
          priority: WishlistPriority.medium,
          dateAdded: now,
        ),
      ];

      final wishlist = Wishlist(
        id: 'wishlist-1',
        createdAt: now,
        updatedAt: now,
        items: items,
      );

      final highPriority = wishlist.getItemsByPriority(WishlistPriority.high);

      expect(highPriority.length, 1);
      expect(highPriority.first.movieTitle, 'High Priority Movie');
    });

    test('User profile updates preserve all data correctly', () {
      // Integration test: copyWith maintains all relationships
      // Tests data integrity across model updates

      final now = DateTime.now();
      final wishlistItems = [
        WishlistItem(
          id: 'item-1',
          movieTitle: 'Wanted',
          priority: WishlistPriority.high,
          dateAdded: now,
        ),
      ];

      final user = User(
        id: 'user-1',
        email: 'original@example.com',
        displayName: 'Original Name',
        movieIds: const ['movie-1', 'movie-2'],
        createdAt: now,
        updatedAt: now,
        wishlist: Wishlist(
          id: 'wishlist-1',
          createdAt: now,
          updatedAt: now,
          items: wishlistItems,
        ),
      );

      // Update displayName
      final updated = user.copyWith(displayName: 'New Name');

      // All other data should be preserved
      expect(updated.displayName, 'New Name');
      expect(updated.email, user.email);
      expect(updated.id, user.id);
      expect(updated.movieIds, user.movieIds);
      expect(updated.wishlist.items.length, 1);
      expect(updated.wishlist.items.first.movieTitle, 'Wanted');
    });

    test('Movie collection and wishlist workflow integration', () {
      // Integration test: Complete user workflow
      // Tests realistic usage pattern

      final now = DateTime.now();

      // User starts with empty collection and wishlist
      final user = User(
        id: 'user-1',
        email: 'collector@example.com',
        displayName: 'Movie Collector',
        createdAt: now,
        updatedAt: now,
        wishlist: Wishlist(
          id: 'wishlist-1',
          createdAt: now,
          updatedAt: now,
          items: const [],
        ),
      );

      // User adds item to wishlist
      final wishlistItem = WishlistItem(
        id: 'wishlist-1',
        movieTitle: 'Desired Movie',
        movieId: 'movie-1',
        priority: WishlistPriority.high,
        dateAdded: now,
      );

      final withWishlistItem = user.addToWishlist(wishlistItem);
      expect(withWishlistItem.wishlist.items.length, 1);
      expect(withWishlistItem.movieCount, 0);

      // User acquires the movie and adds to collection
      final withMovie = withWishlistItem.addMovie('movie-1');
      expect(withMovie.movieCount, 1);
      expect(withMovie.wishlist.items.length, 1); // Wishlist item still there

      // User removes from wishlist (already owned)
      final afterCleanup = withMovie.removeFromWishlist('wishlist-1');
      expect(afterCleanup.movieCount, 1); // Movie still in collection
      expect(afterCleanup.wishlist.items.length, 0); // Wishlist cleaned up
    });
  });
}
