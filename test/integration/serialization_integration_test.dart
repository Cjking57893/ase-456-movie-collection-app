import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/movie.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

void main() {
  group('Integration: Model Serialization and Deserialization', () {
    test('Movie serialization preserves all data through round-trip', () {
      // Integration test: Movie can be stored and retrieved completely
      // Tests full serialization chain

      final now = DateTime.now();
      final movie = Movie(
        id: 'movie-123',
        userId: 'user-456',
        title: 'The Great Film',
        description: 'An epic tale',
        genres: const ['Drama', 'Action'],
        releaseYear: 2024,
        director: 'Famous Director',
        actors: const ['Actor 1', 'Actor 2'],
        runtime: 142,
        rating: 8.5,
        personalRating: 9.0,
        posterUrl: 'https://example.com/poster.jpg',
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.livingRoom,
        specificLocation: 'Shelf 3',
        isWatched: true,
        watchedDate: now,
        notes: 'Excellent cinematography',
        createdAt: now,
        updatedAt: now,
      );

      // Serialize
      final map = movie.toMap();

      // Verify map structure
      expect(map['id'], 'movie-123');
      expect(map['userId'], 'user-456');
      expect(map['title'], 'The Great Film');
      expect(map['genres'], isA<List>());

      // Deserialize
      final reconstructed = Movie.fromMap(map);

      // Verify all fields preserved
      expect(reconstructed.id, movie.id);
      expect(reconstructed.userId, movie.userId);
      expect(reconstructed.title, movie.title);
      expect(reconstructed.description, movie.description);
      expect(reconstructed.genres, movie.genres);
      expect(reconstructed.releaseYear, movie.releaseYear);
      expect(reconstructed.director, movie.director);
      expect(reconstructed.actors, movie.actors);
      expect(reconstructed.runtime, movie.runtime);
      expect(reconstructed.rating, movie.rating);
      expect(reconstructed.personalRating, movie.personalRating);
      expect(reconstructed.format, movie.format);
      expect(reconstructed.storageLocation, movie.storageLocation);
      expect(reconstructed.specificLocation, movie.specificLocation);
      expect(reconstructed.isWatched, movie.isWatched);
      expect(reconstructed.notes, movie.notes);
    });

    test('User serialization maintains collection and wishlist', () {
      // Integration test: User with complex data serializes correctly
      // Tests nested model serialization

      final now = DateTime.now();
      final wishlistItems = [
        WishlistItem(
          id: 'item-1',
          movieTitle: 'Wanted Movie 1',
          priority: WishlistPriority.high,
          notes: 'Must buy!',
          dateAdded: now,
        ),
        WishlistItem(
          id: 'item-2',
          movieTitle: 'Wanted Movie 2',
          priority: WishlistPriority.low,
          dateAdded: now,
        ),
      ];

      final user = User(
        id: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        movieIds: const ['movie-1', 'movie-2', 'movie-3'],
        createdAt: now,
        updatedAt: now,
        wishlist: Wishlist(
          id: 'wishlist-123',
          createdAt: now,
          updatedAt: now,
          items: wishlistItems,
        ),
      );

      // Serialize
      final map = user.toMap();

      // Verify nested structures
      expect(map['movieIds'], isA<List>());
      expect(map['wishlist'], isA<Map>());

      // Deserialize
      final reconstructed = User.fromMap(map);

      // Verify user fields
      expect(reconstructed.id, user.id);
      expect(reconstructed.email, user.email);
      expect(reconstructed.displayName, user.displayName);
      expect(reconstructed.photoUrl, user.photoUrl);

      // Verify movie collection
      expect(reconstructed.movieIds.length, 3);
      expect(reconstructed.movieIds, contains('movie-1'));
      expect(reconstructed.movieIds, contains('movie-2'));
      expect(reconstructed.movieIds, contains('movie-3'));

      // Verify wishlist
      expect(reconstructed.wishlist.items.length, 2);
      expect(reconstructed.wishlist.items[0].movieTitle, 'Wanted Movie 1');
      expect(reconstructed.wishlist.items[0].priority, WishlistPriority.high);
      expect(reconstructed.wishlist.items[1].movieTitle, 'Wanted Movie 2');
    });

    test('Wishlist serialization handles complex items', () {
      // Integration test: Wishlist with various item configurations
      // Tests optional field handling in serialization

      final now = DateTime.now();
      final items = [
        WishlistItem(
          id: 'item-1',
          movieTitle: 'Full Details Movie',
          movieId: 'movie-123',
          priority: WishlistPriority.high,
          notes: 'On sale next week',
          expectedPrice: 29.99,
          whereToFind: 'Best Buy',
          dateAdded: now,
        ),
        WishlistItem(
          id: 'item-2',
          movieTitle: 'Minimal Details Movie',
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

      // Serialize
      final map = wishlist.toMap();

      // Deserialize
      final reconstructed = Wishlist.fromMap(map);

      // Verify full details item
      expect(reconstructed.items[0].movieTitle, 'Full Details Movie');
      expect(reconstructed.items[0].movieId, 'movie-123');
      expect(reconstructed.items[0].notes, 'On sale next week');
      expect(reconstructed.items[0].expectedPrice, 29.99);
      expect(reconstructed.items[0].whereToFind, 'Best Buy');

      // Verify minimal details item (nulls preserved)
      expect(reconstructed.items[1].movieTitle, 'Minimal Details Movie');
      expect(reconstructed.items[1].movieId, isNull);
      expect(reconstructed.items[1].notes, isNull);
      expect(reconstructed.items[1].expectedPrice, isNull);
      expect(reconstructed.items[1].whereToFind, isNull);
    });

    test('Enum serialization works across all models', () {
      // Integration test: Enums serialize consistently
      // Tests enum handling in serialization

      final now = DateTime.now();

      // MovieFormat enum
      final movie = Movie(
        id: 'movie-1',
        userId: 'user-1',
        title: 'Test',
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.basement,
        createdAt: now,
        updatedAt: now,
      );

      final movieMap = movie.toMap();
      final movieReconstructed = Movie.fromMap(movieMap);

      expect(movieReconstructed.format, MovieFormat.bluray);
      expect(movieReconstructed.storageLocation, StorageLocation.basement);

      // WishlistPriority enum
      final wishlistItem = WishlistItem(
        id: 'item-1',
        movieTitle: 'Test',
        priority: WishlistPriority.high,
        dateAdded: now,
      );

      final itemMap = wishlistItem.toMap();
      final itemReconstructed = WishlistItem.fromMap(itemMap);

      expect(itemReconstructed.priority, WishlistPriority.high);
    });

    test('DateTime serialization preserves timestamps', () {
      // Integration test: DateTime fields serialize correctly
      // Tests timestamp handling

      final createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final updatedAt = DateTime(2024, 6, 15, 14, 30, 0);
      final watchedDate = DateTime(2024, 6, 10, 20, 0, 0);

      final movie = Movie(
        id: 'movie-1',
        userId: 'user-1',
        title: 'Test Movie',
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.office,
        isWatched: true,
        watchedDate: watchedDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = movie.toMap();
      final reconstructed = Movie.fromMap(map);

      // Timestamps should match (within millisecond precision)
      expect(
        reconstructed.createdAt.difference(createdAt).inMilliseconds.abs(),
        lessThan(1000),
      );
      expect(
        reconstructed.updatedAt.difference(updatedAt).inMilliseconds.abs(),
        lessThan(1000),
      );
      expect(reconstructed.watchedDate, isNotNull);
      expect(
        reconstructed.watchedDate!.difference(watchedDate).inMilliseconds.abs(),
        lessThan(1000),
      );
    });

    test('Empty collections serialize and deserialize correctly', () {
      // Integration test: Empty lists/maps don't cause issues
      // Tests edge case handling

      final now = DateTime.now();

      // User with empty collection and wishlist
      final user = User(
        id: 'user-1',
        email: 'empty@example.com',
        displayName: 'Empty User',
        movieIds: const [],
        createdAt: now,
        updatedAt: now,
        wishlist: Wishlist(
          id: 'wishlist-1',
          createdAt: now,
          updatedAt: now,
          items: const [],
        ),
      );

      final map = user.toMap();
      final reconstructed = User.fromMap(map);

      expect(reconstructed.movieIds, isEmpty);
      expect(reconstructed.wishlist.items, isEmpty);

      // Movie with empty genres and actors
      final movie = Movie(
        id: 'movie-1',
        userId: 'user-1',
        title: 'Minimal Movie',
        genres: const [],
        actors: const [],
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.storage,
        createdAt: now,
        updatedAt: now,
      );

      final movieMap = movie.toMap();
      final movieReconstructed = Movie.fromMap(movieMap);

      expect(movieReconstructed.genres, isEmpty);
      expect(movieReconstructed.actors, isEmpty);
    });
  });
}
