import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../models/movie.dart';
import 'add_movie_page.dart';
import 'edit_movie_page.dart';
import 'movie_search_page.dart';
import 'wishlist_page.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage>
    with WidgetsBindingObserver {
  final _movieService = ServiceLocator().movieService;
  final _authService = ServiceLocator().authService;
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMovies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadMovies();
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final movies = await _movieService.getUserMovies(userId);
        if (mounted) {
          setState(() {
            _movies = movies;
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
          _errorMessage = 'Could not load movies';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMovie(String movieId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _movieService.deleteMovie(movieId, userId);
        await _loadMovies();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Movie deleted')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete movie'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Movies'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMovies,
            tooltip: 'Refresh Movies',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WishlistPage(),
                ),
              );
            },
            heroTag: 'wishlist',
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            tooltip: 'My Wishlist',
            child: const Icon(Icons.playlist_add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MovieSearchPage(),
                ),
              );
              _loadMovies();
            },
            heroTag: 'search',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddMoviePage()),
              );
              if (result == true) {
                _loadMovies();
              }
            },
            heroTag: 'add',
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ],
      ),
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
            ElevatedButton(onPressed: _loadMovies, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No movies yet'),
            SizedBox(height: 8),
            Text('Tap the + button to add your first movie'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMovies,
      child: ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return _MovieTile(
            movie: movie,
            onEdit: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditMoviePage(movie: movie),
                ),
              );
              if (result == true) {
                _loadMovies();
              }
            },
            onDelete: () => _showDeleteDialog(movie),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Movie'),
        content: Text('Are you sure you want to delete "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteMovie(movie.id);
    }
  }
}

class _MovieTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MovieTile({
    required this.movie,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie.posterUrl!,
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text(
                        movie.title.isNotEmpty
                            ? movie.title[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              )
            : CircleAvatar(
                backgroundColor: Colors.red,
                child: Text(
                  movie.title.isNotEmpty ? movie.title[0].toUpperCase() : 'M',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        title: Text(movie.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.director != null) Text('Dir: ${movie.director}'),
            if (movie.releaseYear != null) Text('Year: ${movie.releaseYear}'),
            Text('Format: ${movie.format.name.toUpperCase()}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
