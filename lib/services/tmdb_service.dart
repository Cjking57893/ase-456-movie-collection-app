import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/tmdb_models.dart';

class TmdbService {
  final http.Client _client;

  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  bool get isConfigured => ApiConfig.hasApiKey;
  Future<TmdbSearchResponse> searchMovies(String query, {int page = 1}) async {
    if (!isConfigured) {
      throw TmdbException('API key not configured');
    }

    if (query.trim().isEmpty) {
      throw TmdbException('Search query cannot be empty');
    }

    try {
      final url = ApiConfig.searchMoviesUrl(query, page: page);
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TmdbSearchResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw TmdbException('Invalid API key');
      } else if (response.statusCode == 404) {
        throw TmdbException('No movies found');
      } else {
        // Propagate non-explicit status codes with generic message;
        // callers differentiate via message only (simple error model kept intentionally).
        throw TmdbException('Search failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TmdbException) {
        rethrow;
      }
      // Distinguish unexpected client/timeout errors from API failures.
      throw TmdbException('Network error: Could not search movies');
    }
  }

  Future<TmdbMovieDetails> getMovieDetails(int movieId) async {
    if (!isConfigured) {
      throw TmdbException('API key not configured');
    }

    try {
      final url = ApiConfig.movieDetailsUrl(movieId);
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TmdbMovieDetails.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw TmdbException('Invalid API key');
      } else if (response.statusCode == 404) {
        throw TmdbException('Movie not found');
      } else {
        throw TmdbException(
          'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is TmdbException) {
        rethrow;
      }
      throw TmdbException('Network error: Could not get movie details');
    }
  }

  Future<TmdbSearchResponse> getPopularMovies({int page = 1}) async {
    if (!isConfigured) {
      throw TmdbException('API key not configured');
    }

    try {
      final url = ApiConfig.popularMoviesUrl(page: page);
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TmdbSearchResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw TmdbException('Invalid API key');
      } else {
        throw TmdbException('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TmdbException) {
        rethrow;
      }
      throw TmdbException('Network error: Could not get popular movies');
    }
  }

  Future<TmdbSearchResponse> getNowPlayingMovies({int page = 1}) async {
    if (!isConfigured) {
      throw TmdbException('API key not configured');
    }

    try {
      final url = ApiConfig.nowPlayingMoviesUrl(page: page);
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TmdbSearchResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw TmdbException('Invalid API key');
      } else {
        throw TmdbException('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TmdbException) {
        rethrow;
      }
      throw TmdbException('Network error: Could not get now playing movies');
    }
  }

  Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.tmdbBaseUrl}/configuration?api_key=$apiKey'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

class TmdbException implements Exception {
  final String message;

  TmdbException(this.message);

  @override
  String toString() => message;
}
