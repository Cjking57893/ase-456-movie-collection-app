import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/movie.dart';

void main() {
  group('Movie Model', () {
    late Movie testMovie;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testMovie = Movie(
        id: 'test-id',
        userId: 'user-123',
        title: 'The Matrix',
        description: 'A hacker discovers reality is a simulation',
        genres: ['Action', 'Sci-Fi'],
        releaseYear: 1999,
        director: 'Wachowski Sisters',
        actors: ['Keanu Reeves', 'Laurence Fishburne'],
        runtime: 136,
        rating: 8.7,
        personalRating: 9.0,
        posterUrl: 'https://example.com/poster.jpg',
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.livingRoom,
        specificLocation: 'Shelf A',
        isWatched: true,
        watchedDate: testDate,
        notes: 'Amazing movie!',
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    test('creates Movie with all properties', () {
      expect(testMovie.id, 'test-id');
      expect(testMovie.userId, 'user-123');
      expect(testMovie.title, 'The Matrix');
      expect(testMovie.description, 'A hacker discovers reality is a simulation');
      expect(testMovie.genres, ['Action', 'Sci-Fi']);
      expect(testMovie.releaseYear, 1999);
      expect(testMovie.director, 'Wachowski Sisters');
      expect(testMovie.actors, ['Keanu Reeves', 'Laurence Fishburne']);
      expect(testMovie.runtime, 136);
      expect(testMovie.rating, 8.7);
      expect(testMovie.personalRating, 9.0);
      expect(testMovie.format, MovieFormat.bluray);
      expect(testMovie.storageLocation, StorageLocation.livingRoom);
      expect(testMovie.isWatched, true);
    });

    test('toMap converts Movie to Map correctly', () {
      final map = testMovie.toMap();

      expect(map['id'], 'test-id');
      expect(map['userId'], 'user-123');
      expect(map['title'], 'The Matrix');
      expect(map['genres'], ['Action', 'Sci-Fi']);
      expect(map['releaseYear'], 1999);
      expect(map['format'], 'bluray');
      expect(map['storageLocation'], 'livingRoom');
      expect(map['isWatched'], true);
    });

    test('fromMap creates Movie from Map correctly', () {
      final map = testMovie.toMap();
      final movieFromMap = Movie.fromMap(map);

      expect(movieFromMap.id, testMovie.id);
      expect(movieFromMap.title, testMovie.title);
      expect(movieFromMap.releaseYear, testMovie.releaseYear);
      expect(movieFromMap.format, testMovie.format);
      expect(movieFromMap.storageLocation, testMovie.storageLocation);
    });

    test('copyWith creates new Movie with updated values', () {
      final updatedMovie = testMovie.copyWith(
        title: 'The Matrix Reloaded',
        releaseYear: 2003,
      );

      expect(updatedMovie.title, 'The Matrix Reloaded');
      expect(updatedMovie.releaseYear, 2003);
      expect(updatedMovie.id, testMovie.id); // Unchanged
      expect(updatedMovie.userId, testMovie.userId); // Unchanged
    });

    test('copyWith with no parameters returns identical movie', () {
      final copiedMovie = testMovie.copyWith();

      expect(copiedMovie.title, testMovie.title);
      expect(copiedMovie.id, testMovie.id);
      expect(copiedMovie.releaseYear, testMovie.releaseYear);
    });

    test('toString returns formatted string', () {
      final result = testMovie.toString();
      expect(result, 'Movie: The Matrix (1999)');
    });

    test('creates Movie with minimal required fields', () {
      final minimalMovie = Movie(
        id: 'min-id',
        userId: 'user-123',
        title: 'Minimal Movie',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(minimalMovie.id, 'min-id');
      expect(minimalMovie.title, 'Minimal Movie');
      expect(minimalMovie.description, isNull);
      expect(minimalMovie.genres, isEmpty);
      expect(minimalMovie.actors, isEmpty);
      expect(minimalMovie.isWatched, false);
      expect(minimalMovie.format, MovieFormat.dvd);
      expect(minimalMovie.storageLocation, StorageLocation.livingRoom);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': 'test-id',
        'userId': 'user-123',
        'title': 'Test Movie',
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
      };

      final movie = Movie.fromMap(map);

      expect(movie.id, 'test-id');
      expect(movie.title, 'Test Movie');
      expect(movie.description, isNull);
      expect(movie.genres, isEmpty);
      expect(movie.isWatched, false);
    });
  });

  group('MovieFormat Enum', () {
    test('has correct values', () {
      expect(MovieFormat.values, [MovieFormat.dvd, MovieFormat.bluray]);
    });

    test('converts to string correctly', () {
      expect(MovieFormat.dvd.name, 'dvd');
      expect(MovieFormat.bluray.name, 'bluray');
    });
  });

  group('StorageLocation Enum', () {
    test('has all expected values', () {
      expect(StorageLocation.values.length, 7);
      expect(StorageLocation.values.contains(StorageLocation.livingRoom), true);
      expect(StorageLocation.values.contains(StorageLocation.bedroom), true);
      expect(StorageLocation.values.contains(StorageLocation.basement), true);
    });
  });
}
