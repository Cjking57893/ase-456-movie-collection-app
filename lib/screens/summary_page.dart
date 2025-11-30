import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../models/movie.dart';

/// Page showing statistics and summaries of the movie collection
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final _movieService = ServiceLocator().movieService;
  final _authService = ServiceLocator().authService;
  final _wishlistService = ServiceLocator().wishlistService;

  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final movies = await _movieService.getUserMovies(userId);
        final wishlist = await _wishlistService.getUserWishlist(userId);
        if (mounted) {
          setState(() {
            _movies = movies;
            _wishlistCount = wishlist?.itemCount ?? 0;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not authenticated';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load data';
          _isLoading = false;
        });
      }
    }
  }

  Map<String, int> get _moviesByFormat {
    final formatCounts = <String, int>{};
    for (var movie in _movies) {
      final format = movie.format.name.toUpperCase();
      formatCounts[format] = (formatCounts[format] ?? 0) + 1;
    }
    return formatCounts;
  }

  Map<String, int> get _moviesByLocation {
    final locationCounts = <String, int>{};
    for (var movie in _movies) {
      final location = _formatLocationName(movie.storageLocation.name);
      locationCounts[location] = (locationCounts[location] ?? 0) + 1;
    }
    return locationCounts;
  }

  Map<String, int> get _moviesByGenre {
    final genreCounts = <String, int>{};
    for (var movie in _movies) {
      for (var genre in movie.genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }
    return genreCounts;
  }

  List<MapEntry<String, int>> get _topGenres {
    final entries = _moviesByGenre.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  int get _watchedCount => _movies.where((m) => m.isWatched).length;
  int get _unwatchedCount => _movies.where((m) => !m.isWatched).length;

  double get _averageRating {
    final moviesWithRating = _movies.where((m) => m.rating != null).toList();
    if (moviesWithRating.isEmpty) return 0;
    final sum = moviesWithRating.fold<double>(
      0,
      (sum, movie) => sum + (movie.rating ?? 0),
    );
    return sum / moviesWithRating.length;
  }

  double get _averagePersonalRating {
    final moviesWithRating =
        _movies.where((m) => m.personalRating != null).toList();
    if (moviesWithRating.isEmpty) return 0;
    final sum = moviesWithRating.fold<double>(
      0,
      (sum, movie) => sum + (movie.personalRating ?? 0),
    );
    return sum / moviesWithRating.length;
  }

  int get _totalRuntime {
    return _movies.fold<int>(
      0,
      (sum, movie) => sum + (movie.runtime ?? 0),
    );
  }

  Movie? get _oldestMovie {
    if (_movies.isEmpty) return null;
    final moviesWithYear = _movies.where((m) => m.releaseYear != null).toList();
    if (moviesWithYear.isEmpty) return null;
    moviesWithYear.sort((a, b) => a.releaseYear!.compareTo(b.releaseYear!));
    return moviesWithYear.first;
  }

  Movie? get _newestMovie {
    if (_movies.isEmpty) return null;
    final moviesWithYear = _movies.where((m) => m.releaseYear != null).toList();
    if (moviesWithYear.isEmpty) return null;
    moviesWithYear.sort((a, b) => b.releaseYear!.compareTo(a.releaseYear!));
    return moviesWithYear.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No movies in collection yet'),
            SizedBox(height: 8),
            Text(
              'Add movies to see statistics',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewSection(),
          const SizedBox(height: 24),
          _buildWatchedSection(),
          const SizedBox(height: 24),
          _buildFormatSection(),
          const SizedBox(height: 24),
          _buildLocationSection(),
          const SizedBox(height: 24),
          _buildGenreSection(),
          const SizedBox(height: 24),
          _buildRatingSection(),
          const SizedBox(height: 24),
          _buildDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    final hours = _totalRuntime ~/ 60;
    final minutes = _totalRuntime % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Movies',
                    _movies.length.toString(),
                    Icons.movie,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Wishlist',
                    _wishlistCount.toString(),
                    Icons.playlist_add,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Total Runtime',
              '${hours}h ${minutes}m',
              Icons.access_time,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchedSection() {
    final watchedPercent = _movies.isEmpty
        ? 0.0
        : (_watchedCount / _movies.length * 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Viewing Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Watched',
                    _watchedCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Unwatched',
                    _unwatchedCount.toString(),
                    Icons.radio_button_unchecked,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: watchedPercent / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${watchedPercent.toStringAsFixed(1)}% watched',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSection() {
    final formats = _moviesByFormat;
    if (formats.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By Format',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...formats.entries.map((entry) {
              final percent = (entry.value / _movies.length * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value} (${percent.toStringAsFixed(0)}%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final locations = _moviesByLocation;
    if (locations.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By Storage Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...locations.entries.map((entry) {
              final percent = (entry.value / _movies.length * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value} (${percent.toStringAsFixed(0)}%)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreSection() {
    final topGenres = _topGenres;
    if (topGenres.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Genres',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topGenres.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Chip(
                      label: Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.blue[100],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_averageRating > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Average TMDB Rating'),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_averagePersonalRating > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Average Personal Rating'),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.blue, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _averagePersonalRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (_averageRating == 0 && _averagePersonalRating == 0)
              const Text(
                'No ratings available',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collection Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_oldestMovie != null)
              _buildDetailRow(
                'Oldest Movie',
                '${_oldestMovie!.title} (${_oldestMovie!.releaseYear})',
                Icons.history,
              ),
            if (_newestMovie != null)
              _buildDetailRow(
                'Newest Movie',
                '${_newestMovie!.title} (${_newestMovie!.releaseYear})',
                Icons.new_releases,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLocationName(String name) {
    return name
        .split(RegExp(r'(?=[A-Z])'))
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
