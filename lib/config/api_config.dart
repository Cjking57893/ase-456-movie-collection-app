class ApiConfig {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  static const String posterSizeSmall = 'w185';
  static const String posterSizeMedium = 'w342';
  static const String posterSizeLarge = 'w500';

  static const String backdropSizeSmall = 'w300';
  static const String backdropSizeMedium = 'w780';
  static const String backdropSizeLarge = 'w1280';

  static const String _tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  static String? _runtimeApiKey;

  static void setApiKey(String apiKey) {
    _runtimeApiKey = apiKey;
  }

  static String? get tmdbApiKey {
    return _runtimeApiKey?.isNotEmpty == true
        ? _runtimeApiKey
        : _tmdbApiKey.isNotEmpty
        ? _tmdbApiKey
        : null;
  }

  static bool get hasApiKey => tmdbApiKey != null && tmdbApiKey!.isNotEmpty;
  static String searchMoviesUrl(String query, {int page = 1}) {
    return '$tmdbBaseUrl/search/movie?api_key=$tmdbApiKey&query=${Uri.encodeComponent(query)}&page=$page';
  }

  static String movieDetailsUrl(int movieId) {
    return '$tmdbBaseUrl/movie/$movieId?api_key=$tmdbApiKey&append_to_response=credits,videos';
  }

  static String popularMoviesUrl({int page = 1}) {
    return '$tmdbBaseUrl/movie/popular?api_key=$tmdbApiKey&page=$page';
  }

  static String nowPlayingMoviesUrl({int page = 1}) {
    return '$tmdbBaseUrl/movie/now_playing?api_key=$tmdbApiKey&page=$page';
  }

  static String getPosterUrl(
    String? posterPath, {
    String size = posterSizeMedium,
  }) {
    if (posterPath == null || posterPath.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$posterPath';
  }

  static String getBackdropUrl(
    String? backdropPath, {
    String size = backdropSizeMedium,
  }) {
    if (backdropPath == null || backdropPath.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$backdropPath';
  }
}
