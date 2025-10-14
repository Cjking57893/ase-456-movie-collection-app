import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final AuthService _authService;

  void setup() {
    _authRepository = FirebaseAuthRepository();
    _userRepository = FirestoreUserRepository();
    _authService = AuthService(
      authRepository: _authRepository,
      userRepository: _userRepository,
    );
  }

  AuthService get authService => _authService;
  AuthRepository get authRepository => _authRepository;
  UserRepository get userRepository => _userRepository;
}