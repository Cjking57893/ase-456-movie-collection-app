import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/movie_repository.dart';
import '../services/auth_service.dart';
import '../services/movie_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final MovieRepository _movieRepository;
  late final AuthService _authService;
  late final MovieService _movieService;

  void setup() {
    _authRepository = FirebaseAuthRepository();
    _userRepository = FirestoreUserRepository();
    _movieRepository = FirestoreMovieRepository();
    _authService = AuthService(
      authRepository: _authRepository,
      userRepository: _userRepository,
    );
    _movieService = MovieService(
      movieRepository: _movieRepository,
      userRepository: _userRepository,
    );
  }

  AuthService get authService => _authService;
  AuthRepository get authRepository => _authRepository;
  UserRepository get userRepository => _userRepository;
  MovieRepository get movieRepository => _movieRepository;
  MovieService get movieService => _movieService;
}