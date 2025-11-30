import 'package:firebase_auth/firebase_auth.dart';
import '../core/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> signIn({required String email, required String password});
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<AuthResult> resetPassword(String email);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthSuccess(result.user!.uid);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_getErrorMessage(e), _getErrorType(e));
    } catch (e) {
      return AuthFailure('Something went wrong', AuthErrorType.unknown);
    }
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(displayName);
      return AuthSuccess(result.user!.uid);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_getErrorMessage(e), _getErrorType(e));
    } catch (e) {
      return AuthFailure('Something went wrong', AuthErrorType.unknown);
    }
  }

  @override
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthSuccess('');
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_getErrorMessage(e), _getErrorType(e));
    } catch (e) {
      return AuthFailure('Something went wrong', AuthErrorType.unknown);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getErrorMessage(FirebaseAuthException e) {
    // Map Firebase error codes to user-friendly messages. Keep messages short for snackbars.
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  AuthErrorType _getErrorType(FirebaseAuthException e) {
    // Provide a semantic error type so UI can react (e.g., highlight specific field).
    switch (e.code) {
      case 'weak-password':
        return AuthErrorType.weakPassword;
      case 'email-already-in-use':
        return AuthErrorType.emailAlreadyInUse;
      case 'user-not-found':
        return AuthErrorType.userNotFound;
      case 'wrong-password':
        return AuthErrorType.wrongPassword;
      case 'invalid-email':
        return AuthErrorType.invalidEmail;
      case 'user-disabled':
        return AuthErrorType.userDisabled;
      case 'too-many-requests':
        return AuthErrorType.tooManyRequests;
      default:
        return AuthErrorType.unknown;
    }
  }
}
