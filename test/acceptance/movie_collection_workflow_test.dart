import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/movie.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

/// Acceptance Test: Movie Collection Management Workflow
/// 
/// Business Requirements Verified:
/// - Users can add movies to their personal collection
/// - Movie details include title, genres, director, format, location
/// - Users can track physical movie formats (DVD, Blu-ray)
/// - Users can specify storage locations for physical media
/// - Movies can be marked as watched with dates
/// - Personal ratings and notes can be added to movies
/// - Collection operations maintain data integrity
void main() {
  group('Acceptance: Movie Collection Workflow', () {
    test('User can add a new movie to their collection', () {
      // GIVEN: A user with empty collection
      final now = DateTime.now();
      var user = User(
        id: 'user_123',
        email: 'collector@example.com',
        displayName: 'Movie Collector',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(
          id: 'wishlist_123',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // AND: A new movie to add
      const movieId = 'movie_1';
      final movie = Movie(
        id: movieId,
        userId: user.id,
        title: 'The Matrix',
        description: 'A hacker discovers reality is a simulation',
        genres: ['Action', 'Sci-Fi'],
        releaseYear: 1999,
        director: 'The Wachowskis',
        actors: ['Keanu Reeves', 'Laurence Fishburne'],
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.livingRoom,
        createdAt: now,
        updatedAt: now,
      );

      // WHEN: User adds movie to collection
      user = user.addMovie(movieId);

      // THEN: Movie is in collection
      expect(user.hasMovie(movieId), true);
      expect(user.movieCount, 1);
      expect(user.movieIds, contains(movieId));
      
      // AND: Movie has correct details
      expect(movie.title, 'The Matrix');
      expect(movie.userId, user.id);
      expect(movie.genres, contains('Sci-Fi'));
      expect(movie.format, MovieFormat.bluray);
    });

    test('Movie tracks physical format and storage location', () {
      // GIVEN: Different movie formats
      final now = DateTime.now();
      
      final dvdMovie = Movie(
        id: 'movie_dvd',
        userId: 'user_1',
        title: 'Classic Movie',
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.bedroom,
        specificLocation: 'Shelf A, Row 2',
        createdAt: now,
        updatedAt: now,
      );

      final blurayMovie = Movie(
        id: 'movie_bluray',
        userId: 'user_1',
        title: 'Modern Movie',
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.office,
        specificLocation: 'Cabinet B',
        createdAt: now,
        updatedAt: now,
      );

      // THEN: Format is correctly stored
      expect(dvdMovie.format, MovieFormat.dvd);
      expect(blurayMovie.format, MovieFormat.bluray);
      
      // AND: Storage location is tracked
      expect(dvdMovie.storageLocation, StorageLocation.bedroom);
      expect(dvdMovie.specificLocation, 'Shelf A, Row 2');
      expect(blurayMovie.storageLocation, StorageLocation.office);
      expect(blurayMovie.specificLocation, 'Cabinet B');
    });

    test('Movie can be marked as watched with rating', () {
      // GIVEN: An unwatched movie
      final now = DateTime.now();
      var movie = Movie(
        id: 'movie_1',
        userId: 'user_1',
        title: 'Inception',
        isWatched: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(movie.isWatched, false);
      expect(movie.watchedDate, isNull);
      expect(movie.personalRating, isNull);

      // WHEN: User watches and rates the movie
      final watchedDate = DateTime.now();
      movie = movie.copyWith(
        isWatched: true,
        watchedDate: watchedDate,
        personalRating: 4.5,
        notes: 'Mind-bending plot, excellent cinematography',
      );

      // THEN: Watch status is updated
      expect(movie.isWatched, true);
      expect(movie.watchedDate, watchedDate);
      expect(movie.personalRating, 4.5);
      expect(movie.notes, contains('Mind-bending'));
    });

    test('Movie metadata is properly maintained', () {
      // GIVEN: A movie with complete metadata
      final now = DateTime.now();
      final movie = Movie(
        id: 'movie_meta',
        userId: 'user_1',
        title: 'The Godfather',
        description: 'The aging patriarch of an organized crime dynasty transfers control',
        genres: ['Crime', 'Drama'],
        releaseYear: 1972,
        director: 'Francis Ford Coppola',
        actors: ['Marlon Brando', 'Al Pacino', 'James Caan'],
        runtime: 175,
        rating: 9.2,
        posterUrl: 'https://example.com/godfather.jpg',
        createdAt: now,
        updatedAt: now,
      );

      // THEN: All metadata is accessible
      expect(movie.title, 'The Godfather');
      expect(movie.releaseYear, 1972);
      expect(movie.director, 'Francis Ford Coppola');
      expect(movie.runtime, 175);
      expect(movie.rating, 9.2);
      expect(movie.genres.length, 2);
      expect(movie.actors.length, 3);
      expect(movie.posterUrl, isNotNull);
    });

    test('User collection tracks movie ownership', () {
      // GIVEN: Multiple users
      final now = DateTime.now();
      final user1 = User(
        id: 'user_1',
        email: 'user1@example.com',
        displayName: 'User One',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(id: 'wishlist_1', createdAt: now, updatedAt: now),
      );

      final user2 = User(
        id: 'user_2',
        email: 'user2@example.com',
        displayName: 'User Two',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(id: 'wishlist_2', createdAt: now, updatedAt: now),
      );

      // AND: Movies owned by different users
      final movie1 = Movie(
        id: 'movie_1',
        userId: user1.id,
        title: 'Movie for User 1',
        createdAt: now,
        updatedAt: now,
      );

      final movie2 = Movie(
        id: 'movie_2',
        userId: user2.id,
        title: 'Movie for User 2',
        createdAt: now,
        updatedAt: now,
      );

      // THEN: Movies belong to correct users
      expect(movie1.userId, user1.id);
      expect(movie2.userId, user2.id);
      expect(movie1.userId, isNot(movie2.userId));
    });

    test('Complete movie management workflow', () {
      // GIVEN: A user building their collection
      final now = DateTime.now();
      var user = User(
        id: 'workflow_user',
        email: 'workflow@example.com',
        displayName: 'Workflow Test',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(id: 'wishlist_w', createdAt: now, updatedAt: now),
      );

      // WHEN: User adds first movie
      var movie1 = Movie(
        id: 'movie_w1',
        userId: user.id,
        title: 'First Movie',
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.livingRoom,
        isWatched: false,
        createdAt: now,
        updatedAt: now,
      );
      user = user.addMovie(movie1.id);

      // THEN: Collection has one movie
      expect(user.movieCount, 1);

      // WHEN: User adds more movies
      user = user.addMovie('movie_w2');
      user = user.addMovie('movie_w3');

      // THEN: Collection grows
      expect(user.movieCount, 3);

      // WHEN: User watches first movie
      movie1 = movie1.copyWith(
        isWatched: true,
        watchedDate: DateTime.now(),
        personalRating: 4.0,
      );

      // THEN: Movie status is updated
      expect(movie1.isWatched, true);
      expect(movie1.personalRating, 4.0);

      // WHEN: User reorganizes collection
      movie1 = movie1.copyWith(
        format: MovieFormat.bluray,
        storageLocation: StorageLocation.office,
        specificLocation: 'Blu-ray Cabinet, Top Shelf',
      );

      // THEN: Storage info is updated
      expect(movie1.format, MovieFormat.bluray);
      expect(movie1.storageLocation, StorageLocation.office);

      // WHEN: User removes a movie
      user = user.removeMovie('movie_w2');

      // THEN: Collection decreases
      expect(user.movieCount, 2);
      expect(user.hasMovie('movie_w2'), false);
    });

    test('Movie cannot be added to collection twice', () {
      // GIVEN: A user with a movie already in collection
      final now = DateTime.now();
      var user = User(
        id: 'user_dup',
        email: 'duplicate@example.com',
        displayName: 'Dup Test',
        createdAt: now,
        updatedAt: now,
        movieIds: ['movie_existing'],
        wishlist: Wishlist(id: 'wishlist_dup', createdAt: now, updatedAt: now),
      );

      expect(user.hasMovie('movie_existing'), true);
      expect(user.movieCount, 1);

      // WHEN: User tries to add same movie again
      user = user.addMovie('movie_existing');

      // THEN: Movie is not duplicated
      expect(user.movieCount, 1);
      expect(user.movieIds.where((id) => id == 'movie_existing').length, 1);
    });
  });
}
