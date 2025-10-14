class AppConstants {
  static const String appName = 'Movie Collection';

  // Validation
  static const int minPasswordLength = 6;
  static const int searchMinLength = 2;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Network
  static const int networkTimeoutSeconds = 10;
  static const int debounceDelayMs = 500;

  // Messages
  static const String genericError = 'Something went wrong';
  static const String networkError = 'Check your internet connection';
  static const String accountCreated = 'Account created';
  static const String passwordResetSent = 'Password reset email sent!';
  static const String apiKeyRequired = 'TMDB API key required for search';
}
