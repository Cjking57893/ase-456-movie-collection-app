import 'dart:async';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../core/service_locator.dart';
import '../models/tmdb_models.dart';
import '../models/movie.dart';
import '../models/wishlist.dart';

class MovieSearchPage extends StatefulWidget {
  const MovieSearchPage({super.key});

  @override
  State<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final _searchController = TextEditingController();
  final _tmdbService = ServiceLocator().tmdbService;
  final _movieService = ServiceLocator().movieService;
  final _wishlistService = ServiceLocator().wishlistService;
  final _authService = ServiceLocator().authService;

  bool _isLoading = false;
  List<TmdbMovie> _searchResults = [];
  String? _errorMessage;
  int? _importingMovieId;
  bool _hasImportedMovies = false;
  Timer? _debounceTimer;
  String _lastSearchQuery = '';
  
  // Filter variables
  int? _minYear;
  int? _maxYear;
  double? _minRating;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    if (trimmedQuery == _lastSearchQuery) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _search(trimmedQuery);
    });
  }

  Future<void> _search(String query) async {
    _lastSearchQuery = query;

    try {
      final response = await _tmdbService.searchMovies(query);
      if (mounted) {
        setState(() {
          _searchResults = response.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchMovies() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    await _search(query);
  }

  List<TmdbMovie> get _filteredResults {
    var filtered = _searchResults;

    if (_minYear != null) {
      filtered = filtered.where((movie) {
        return movie.releaseYear != null && movie.releaseYear! >= _minYear!;
      }).toList();
    }

    if (_maxYear != null) {
      filtered = filtered.where((movie) {
        return movie.releaseYear != null && movie.releaseYear! <= _maxYear!;
      }).toList();
    }

    if (_minRating != null) {
      filtered = filtered.where((movie) {
        return movie.voteAverage >= _minRating!;
      }).toList();
    }

    return filtered;
  }

  Future<void> _addToWishlist(TmdbMovie tmdbMovie) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _showError('User not authenticated');
      return;
    }

    try {
      await _wishlistService.addWishlistItem(
        userId: userId,
        movieTitle: tmdbMovie.title,
        movieId: tmdbMovie.id.toString(),
        priority: WishlistPriority.medium,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${tmdbMovie.title}" added to wishlist'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Could not add to wishlist: ${e.toString()}');
      }
    }
  }

  Future<void> _importMovie(TmdbMovie tmdbMovie) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _showError('User not authenticated');
      return;
    }

    setState(() {
      _importingMovieId = tmdbMovie.id;
    });

    try {
      final details = await _tmdbService.getMovieDetails(tmdbMovie.id);

      await _movieService.addMovie(
        userId: userId,
        title: details.title,
        description: details.overview?.isNotEmpty == true
            ? details.overview
            : null,
        genres: details.genreNames,
        releaseYear: details.releaseYear,
        director: details.director,
        actors: details.mainActors,
        runtime: details.runtime,
        rating: details.voteAverage > 0 ? details.voteAverage : null,
        format: MovieFormat.dvd,
        storageLocation: StorageLocation.livingRoom,
        isWatched: false,
        posterUrl: details.posterPath != null
            ? ApiConfig.getPosterUrl(details.posterPath)
            : null,
      );

      if (mounted) {
        setState(() {
          _hasImportedMovies = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${details.title}" to your collection'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Could not import movie: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _importingMovieId = null;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showFilterDialog() async {
    final minYearController = TextEditingController(
      text: _minYear?.toString() ?? '',
    );
    final maxYearController = TextEditingController(
      text: _maxYear?.toString() ?? '',
    );
    double? tempMinRating = _minRating;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Results'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Year Range',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minYearController,
                        decoration: const InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxYearController,
                        decoration: const InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Minimum Rating',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempMinRating ?? 0,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        label: tempMinRating == null
                            ? 'Any'
                            : tempMinRating!.toStringAsFixed(1),
                        onChanged: (value) {
                          setDialogState(() {
                            tempMinRating = value > 0 ? value : null;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        tempMinRating == null
                            ? 'Any'
                            : tempMinRating!.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _minYear = null;
                  _maxYear = null;
                  _minRating = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _minYear = minYearController.text.isEmpty
                      ? null
                      : int.tryParse(minYearController.text);
                  _maxYear = maxYearController.text.isEmpty
                      ? null
                      : int.tryParse(maxYearController.text);
                  _minRating = tempMinRating;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchMovies,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final displayResults = _filteredResults;

    if (displayResults.isEmpty && _searchResults.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.filter_list_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No movies match your filters',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your filter criteria',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty &&
        _searchController.text.isNotEmpty &&
        !_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No movies found', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text(
                'Try searching with a different title',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Search Movies', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text(
                'Start typing to search the TMDB database',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: displayResults.length,
      itemBuilder: (context, index) {
        final movie = displayResults[index];
        return _MovieSearchTile(
          movie: movie,
          isImporting: _importingMovieId == movie.id,
          onImport: () => _importMovie(movie),
          onAddToWishlist: () => _addToWishlist(movie),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_hasImportedMovies);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: (_minYear != null || _maxYear != null || _minRating != null)
                  ? Colors.orange
                  : null,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Results',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                prefixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchMovies(),
              onChanged: (value) {
                _onSearchChanged(value);
                setState(() {});
              },
            ),
          ),
          if (_minYear != null || _maxYear != null || _minRating != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_minYear != null || _maxYear != null)
                    Chip(
                      label: Text(
                        'Year: ${_minYear ?? '?'} - ${_maxYear ?? '?'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _minYear = null;
                          _maxYear = null;
                        });
                      },
                    ),
                  if (_minRating != null)
                    Chip(
                      label: Text(
                        'Rating: ${_minRating!.toStringAsFixed(1)}+',
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _minRating = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }
}

class _MovieSearchTile extends StatelessWidget {
  final TmdbMovie movie;
  final bool isImporting;
  final VoidCallback onImport;
  final VoidCallback onAddToWishlist;

  const _MovieSearchTile({
    required this.movie,
    required this.isImporting,
    required this.onImport,
    required this.onAddToWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: movie.posterPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ApiConfig.getPosterUrl(movie.posterPath),
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 75,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.movie, color: Colors.grey),
                    );
                  },
                ),
              )
            : Container(
                width: 50,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie, color: Colors.grey),
              ),
        title: Text(
          movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.releaseYear != null)
              Text('Released: ${movie.releaseYear}'),
            if (movie.overview?.isNotEmpty == true)
              Text(
                movie.overview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (movie.voteAverage > 0)
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${movie.voteAverage.toStringAsFixed(1)}/10'),
                ],
              ),
          ],
        ),
        trailing: isImporting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: onAddToWishlist,
                    tooltip: 'Add to Wishlist',
                    color: Colors.orange,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: onImport,
                    tooltip: 'Add to Collection',
                    color: Colors.green,
                  ),
                ],
              ),
        isThreeLine: true,
      ),
    );
  }
}
