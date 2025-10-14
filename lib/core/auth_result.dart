sealed class AuthResult {}

class AuthSuccess extends AuthResult {
  final String userId;
  AuthSuccess(this.userId);
}

class AuthFailure extends AuthResult {
  final String message;
  final AuthErrorType type;
  
  AuthFailure(this.message, this.type);
}

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