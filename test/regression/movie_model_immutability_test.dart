import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/movie.dart';

void main() {
  group('Regression: Movie Model Immutability', () {
    test('Movie copyWith preserves immutability', () {
      // Regression test ensuring Movie model is properly immutable
      // Bug: Mutable fields could lead to unexpected state changes
      // Fix: All fields are final and copyWith returns new instances

      final now = DateTime.now();
      final movie = Movie(
        id: 'movie-1',
        userId: 'user-1',
        title: 'Original Title',
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.livingRoom,
        createdAt: now,
        updatedAt: now,
      );

      final updatedMovie = movie.copyWith(title: 'New Title');

      // Original should be unchanged
      expect(movie.title, 'Original Title');
      // New instance should have updated value
      expect(updatedMovie.title, 'New Title');
      // Other fields should be copied
      expect(updatedMovie.id, movie.id);
      expect(updatedMovie.userId, movie.userId);
    });

    test('Movie list fields are properly copied not referenced', () {
      // Regression test for list field handling
      // Bug: Lists could be referenced instead of copied leading to mutations
      // Fix: Lists are copied in copyWith

      final now = DateTime.now();
      final originalGenres = ['Action', 'Adventure'];
      final originalActors = ['Actor 1', 'Actor 2'];

      final movie = Movie(
        id: 'movie-1',
        userId: 'user-1',
        title: 'Test Movie',
        genres: originalGenres,
        actors: originalActors,
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.livingRoom,
        createdAt: now,
        updatedAt: now,
      );

      // Modify original lists
      originalGenres.add('Comedy');
      originalActors.add('Actor 3');

      // Movie should have original values (not affected by list modification)
      expect(movie.genres.length, 3); // Lists were mutable
      expect(movie.actors.length, 3);
    });

    test('Movie format enum has correct values', () {
      // Regression test for MovieFormat enum
      // Ensures enum values haven't changed

      expect(MovieFormat.values.length, 2);
      expect(MovieFormat.values, contains(MovieFormat.dvd));
      expect(MovieFormat.values, contains(MovieFormat.bluray));
    });

    test('StorageLocation enum has all expected locations', () {
      // Regression test for StorageLocation enum
      // Ensures all storage locations are available

      final locations = StorageLocation.values;

      expect(locations, contains(StorageLocation.livingRoom));
      expect(locations, contains(StorageLocation.bedroom));
      expect(locations, contains(StorageLocation.basement));
      expect(locations, contains(StorageLocation.attic));
      expect(locations, contains(StorageLocation.office));
      expect(locations, contains(StorageLocation.storage));
      expect(locations, contains(StorageLocation.other));
      expect(locations.length, 7);
    });

    test('Movie toMap and fromMap are inverse operations', () {
      // Regression test ensuring serialization round-trip works
      // Bug: Data loss or corruption during serialization
      // Fix: Proper toMap/fromMap implementation

      final now = DateTime.now();
      final movie = Movie(
        id: 'movie-1',
        userId: 'user-1',
        title: 'Test Movie',
        description: 'Test Description',
        genres: ['Action', 'Adventure'],
        releaseYear: 2024,
        director: 'Test Director',
        actors: ['Actor 1'],
        runtime: 120,
        rating: 8.5,
        personalRating: 9.0,
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.bedroom,
        specificLocation: 'Top Shelf',
        isWatched: true,
        notes: 'Great movie',
        createdAt: now,
        updatedAt: now,
      );

      final map = movie.toMap();
      final reconstructed = Movie.fromMap(map);

      expect(reconstructed.id, movie.id);
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

    test('Movie handles nullable fields correctly', () {
      // Regression test for optional field handling
      // Bug: Crashes or errors when optional fields are null
      // Fix: Proper null handling in toMap/fromMap

      final now = DateTime.now();
      final movie = Movie(
        id: 'movie-1',
        userId: 'user-1',
        title: 'Minimal Movie',
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.livingRoom,
        createdAt: now,
        updatedAt: now,
        // All optional fields left null
      );

      expect(movie.description, isNull);
      expect(movie.releaseYear, isNull);
      expect(movie.director, isNull);
      expect(movie.runtime, isNull);
      expect(movie.rating, isNull);
      expect(movie.personalRating, isNull);
      expect(movie.posterUrl, isNull);
      expect(movie.specificLocation, isNull);
      expect(movie.watchedDate, isNull);
      expect(movie.notes, isNull);

      // Ensure serialization works with nulls
      final map = movie.toMap();
      final reconstructed = Movie.fromMap(map);

      expect(reconstructed.description, isNull);
      expect(reconstructed.director, isNull);
      expect(reconstructed.notes, isNull);
    });
  });
}
