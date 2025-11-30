/// Represents the result of an authentication operation
sealed class AuthResult {}

/// Successful authentication result with user ID
class AuthSuccess extends AuthResult {
  final String userId;
  AuthSuccess(this.userId);
}

/// Failed authentication result with error message and type
class AuthFailure extends AuthResult {
  final String message;
  final AuthErrorType type;

  AuthFailure(this.message, this.type);
}

/// Types of authentication errors that can occur
enum AuthErrorType {
  weakPassword,
  emailAlreadyInUse,
  userNotFound,
  wrongPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  networkError,
  unknown,
}
