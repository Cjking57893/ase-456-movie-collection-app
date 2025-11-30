import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

/// Repository interface for movie storage operations
abstract class MovieRepository {
  Future<void> addMovie(Movie movie);
  Future<List<Movie>> getUserMovies(String userId);
  Future<void> updateMovie(Movie movie);
  Future<void> deleteMovie(String movieId);
  Future<Movie?> getMovie(String movieId);
}

/// Firestore implementation of MovieRepository
/// Stores movies in the 'movies' collection
class FirestoreMovieRepository implements MovieRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'movies';

  FirestoreMovieRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addMovie(Movie movie) async {
    await _firestore
        .collection(_collectionName)
        .doc(movie.id)
        .set(movie.toMap());
  }

  @override
  Future<List<Movie>> getUserMovies(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('title')
          .get();

      return snapshot.docs.map((doc) => Movie.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      // If ordering fails (e.g., missing index), fetch without ordering and sort in-memory
      if (e.code == 'failed-precondition') {
        final snapshot = await _firestore
            .collection(_collectionName)
            .where('userId', isEqualTo: userId)
            .get();

        final movies = snapshot.docs
            .map((doc) => Movie.fromMap(doc.data()))
            .toList();

        movies.sort((a, b) => a.title.compareTo(b.title));
        return movies;
      }
      rethrow;
    }
  }

  @override
  Future<void> updateMovie(Movie movie) async {
    await _firestore
        .collection(_collectionName)
        .doc(movie.id)
        .update(movie.toMap());
  }

  @override
  Future<void> deleteMovie(String movieId) async {
    await _firestore.collection(_collectionName).doc(movieId).delete();
  }

  @override
  Future<Movie?> getMovie(String movieId) async {
    final doc = await _firestore.collection(_collectionName).doc(movieId).get();

    if (doc.exists) {
      return Movie.fromMap(doc.data()!);
    }
    return null;
  }
}
