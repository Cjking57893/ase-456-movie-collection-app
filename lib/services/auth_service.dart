import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../core/auth_result.dart';
import '../models/user.dart';
import '../models/wishlist.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthService({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  Stream<firebase_auth.User?> get authStateChanges => 
      _authRepository.authStateChanges;

  firebase_auth.User? get currentUser => _authRepository.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    return await _authRepository.signIn(
      email: email,
      password: password,
    );
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result is AuthSuccess) {
      final now = DateTime.now();
      final user = User(
        id: result.userId,
        email: email,
        displayName: displayName,
        photoUrl: null,
        createdAt: now,
        updatedAt: now,
        movieIds: const [],
        wishlist: Wishlist(
          id: 'wishlist_${result.userId}',
          createdAt: now,
          updatedAt: now,
          items: const [],
        ),
      );

      try {
        await _userRepository.createUser(user);
      } catch (e) {
        await _authRepository.signOut();
        return AuthFailure('Failed to complete account setup', AuthErrorType.unknown);
      }
    }

    return result;
  }

  Future<AuthResult> resetPassword(String email) async {
    return await _authRepository.resetPassword(email);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<User?> getCurrentAppUser() async {
    final firebaseUser = currentUser;
    if (firebaseUser == null) return null;

    return await _userRepository.getUser(firebaseUser.uid);
  }
}