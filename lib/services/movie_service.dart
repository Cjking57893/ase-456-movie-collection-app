import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../repositories/user_repository.dart';

/// Manages movie collection operations including CRUD operations
/// Coordinates between movie storage and user movie tracking
class MovieService {
  final MovieRepository _movieRepository;
  final UserRepository _userRepository;

  MovieService({
    required MovieRepository movieRepository,
    required UserRepository userRepository,
  }) : _movieRepository = movieRepository,
       _userRepository = userRepository;

  Future<void> addMovie({
    required String userId,
    required String title,
    String? description,
    List<String>? genres,
    int? releaseYear,
    String? director,
    List<String>? actors,
    int? runtime,
    double? rating,
    double? personalRating,
    String? posterUrl,
    MovieFormat? format,
    StorageLocation? storageLocation,
    String? specificLocation,
    bool? isWatched,
    DateTime? watchedDate,
    String? notes,
  }) async {
    final movieId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final movie = Movie(
      id: movieId,
      userId: userId,
      title: title,
      description: description,
      genres: genres ?? [],
      releaseYear: releaseYear,
      director: director,
      actors: actors ?? [],
      runtime: runtime,
      rating: rating,
      personalRating: personalRating,
      posterUrl: posterUrl,
      format: format ?? MovieFormat.dvd,
      storageLocation: storageLocation ?? StorageLocation.livingRoom,
      specificLocation: specificLocation,
      isWatched: isWatched ?? false,
      watchedDate: watchedDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await _movieRepository.addMovie(movie);

    final user = await _userRepository.getUser(userId);
    if (user != null) {
      final updatedUser = user.addMovie(movieId);
      await _userRepository.updateUser(updatedUser);
    }
  }

  Future<List<Movie>> getUserMovies(String userId) async {
    return await _movieRepository.getUserMovies(userId);
  }

  Future<void> updateMovie({
    required String movieId,
    required String userId,
    required String title,
    String? description,
    List<String>? genres,
    int? releaseYear,
    String? director,
    List<String>? actors,
    int? runtime,
    double? rating,
    double? personalRating,
    String? posterUrl,
    MovieFormat? format,
    StorageLocation? storageLocation,
    String? specificLocation,
    bool? isWatched,
    DateTime? watchedDate,
    String? notes,
  }) async {
    final existingMovie = await _movieRepository.getMovie(movieId);
    if (existingMovie == null || existingMovie.userId != userId) {
      throw Exception('Movie not found or access denied');
    }

    final updatedMovie = existingMovie.copyWith(
      title: title,
      description: description,
      genres: genres,
      releaseYear: releaseYear,
      director: director,
      actors: actors,
      runtime: runtime,
      rating: rating,
      personalRating: personalRating,
      posterUrl: posterUrl,
      format: format,
      storageLocation: storageLocation,
      specificLocation: specificLocation,
      isWatched: isWatched,
      watchedDate: watchedDate,
      notes: notes,
      updatedAt: DateTime.now(),
    );

    await _movieRepository.updateMovie(updatedMovie);
  }

  Future<void> deleteMovie(String movieId, String userId) async {
    final movie = await _movieRepository.getMovie(movieId);
    if (movie == null || movie.userId != userId) {
      throw Exception('Movie not found or access denied');
    }

    await _movieRepository.deleteMovie(movieId);

    final user = await _userRepository.getUser(userId);
    if (user != null) {
      final updatedUser = user.removeMovie(movieId);
      await _userRepository.updateUser(updatedUser);
    }
  }

  Future<Movie?> getMovie(String movieId, String userId) async {
    final movie = await _movieRepository.getMovie(movieId);
    if (movie?.userId != userId) {
      return null;
    }
    return movie;
  }
}
