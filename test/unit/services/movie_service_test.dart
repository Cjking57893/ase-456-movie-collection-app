import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:movie_collection_app/services/movie_service.dart';
import 'package:movie_collection_app/repositories/movie_repository.dart';
import 'package:movie_collection_app/repositories/user_repository.dart';
import 'package:movie_collection_app/models/movie.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

import 'movie_service_test.mocks.dart';

@GenerateMocks([MovieRepository, UserRepository])
void main() {
  group('MovieService', () {
    late MovieService movieService;
    late MockMovieRepository mockMovieRepository;
    late MockUserRepository mockUserRepository;
    late DateTime testDate;

    setUp(() {
      mockMovieRepository = MockMovieRepository();
      mockUserRepository = MockUserRepository();
      movieService = MovieService(
        movieRepository: mockMovieRepository,
        userRepository: mockUserRepository,
      );
      testDate = DateTime(2024, 1, 1);
    });

    group('getUserMovies', () {
      test('returns list of user movies', () async {
        final movies = [
          Movie(
            id: 'movie1',
            userId: 'user-123',
            title: 'Inception',
            createdAt: testDate,
            updatedAt: testDate,
          ),
          Movie(
            id: 'movie2',
            userId: 'user-123',
            title: 'The Matrix',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        when(mockMovieRepository.getUserMovies('user-123'))
            .thenAnswer((_) async => movies);

        final result = await movieService.getUserMovies('user-123');

        expect(result.length, 2);
        expect(result[0].title, 'Inception');
        expect(result[1].title, 'The Matrix');
        verify(mockMovieRepository.getUserMovies('user-123')).called(1);
      });

      test('returns empty list when user has no movies', () async {
        when(mockMovieRepository.getUserMovies('user-123'))
            .thenAnswer((_) async => []);

        final result = await movieService.getUserMovies('user-123');

        expect(result, isEmpty);
      });
    });

    group('deleteMovie', () {
      test('deletes movie and updates user', () async {
        final movie = Movie(
          id: 'movie1',
          userId: 'user-123',
          title: 'Test Movie',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final user = User(
          id: 'user-123',
          email: 'test@example.com',
          displayName: 'Test User',
          movieIds: const ['movie1', 'movie2'],
          createdAt: testDate,
          updatedAt: testDate,
          wishlist: Wishlist(
            id: 'wishlist-123',
            createdAt: testDate,
            updatedAt: testDate,
          ),
        );

        when(mockMovieRepository.getMovie('movie1'))
            .thenAnswer((_) async => movie);
        when(mockMovieRepository.deleteMovie('movie1'))
            .thenAnswer((_) async => Future.value());
        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => user);
        when(mockUserRepository.updateUser(any))
            .thenAnswer((_) async => Future.value());

        await movieService.deleteMovie('movie1', 'user-123');

        verify(mockMovieRepository.deleteMovie('movie1')).called(1);
        verify(mockUserRepository.updateUser(any)).called(1);
      });

      test('throws exception when movie not found', () async {
        when(mockMovieRepository.getMovie('nonexistent'))
            .thenAnswer((_) async => null);

        expect(
          () => movieService.deleteMovie('nonexistent', 'user-123'),
          throwsA(isA<Exception>()),
        );

        verifyNever(mockMovieRepository.deleteMovie(any));
      });

      test('throws exception when user does not own movie', () async {
        final movie = Movie(
          id: 'movie1',
          userId: 'other-user',
          title: 'Test Movie',
          createdAt: testDate,
          updatedAt: testDate,
        );

        when(mockMovieRepository.getMovie('movie1'))
            .thenAnswer((_) async => movie);

        expect(
          () => movieService.deleteMovie('movie1', 'user-123'),
          throwsA(isA<Exception>()),
        );

        verifyNever(mockMovieRepository.deleteMovie(any));
      });
    });

    group('getMovie', () {
      test('returns movie when user owns it', () async {
        final movie = Movie(
          id: 'movie1',
          userId: 'user-123',
          title: 'Test Movie',
          createdAt: testDate,
          updatedAt: testDate,
        );

        when(mockMovieRepository.getMovie('movie1'))
            .thenAnswer((_) async => movie);

        final result = await movieService.getMovie('movie1', 'user-123');

        expect(result, isNotNull);
        expect(result!.title, 'Test Movie');
      });

      test('returns null when user does not own movie', () async {
        final movie = Movie(
          id: 'movie1',
          userId: 'other-user',
          title: 'Test Movie',
          createdAt: testDate,
          updatedAt: testDate,
        );

        when(mockMovieRepository.getMovie('movie1'))
            .thenAnswer((_) async => movie);

        final result = await movieService.getMovie('movie1', 'user-123');

        expect(result, isNull);
      });

      test('returns null when movie not found', () async {
        when(mockMovieRepository.getMovie('nonexistent'))
            .thenAnswer((_) async => null);

        final result = await movieService.getMovie('nonexistent', 'user-123');

        expect(result, isNull);
      });
    });
  });
}
