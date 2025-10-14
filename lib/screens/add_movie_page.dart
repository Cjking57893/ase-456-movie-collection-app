import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../models/movie.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _directorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _releaseYearController = TextEditingController();
  final _runtimeController = TextEditingController();
  final _ratingController = TextEditingController();
  final _personalRatingController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _movieService = ServiceLocator().movieService;
  final _authService = ServiceLocator().authService;

  MovieFormat _selectedFormat = MovieFormat.dvd;
  StorageLocation _selectedLocation = StorageLocation.livingRoom;
  bool _isWatched = false;
  bool _isLoading = false;
  final List<String> _genres = [];
  final List<String> _actors = [];

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _descriptionController.dispose();
    _releaseYearController.dispose();
    _runtimeController.dispose();
    _ratingController.dispose();
    _personalRatingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _movieService.addMovie(
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        genres: _genres,
        releaseYear: _releaseYearController.text.trim().isEmpty
            ? null
            : int.tryParse(_releaseYearController.text.trim()),
        director: _directorController.text.trim().isEmpty
            ? null
            : _directorController.text.trim(),
        actors: _actors,
        runtime: _runtimeController.text.trim().isEmpty
            ? null
            : int.tryParse(_runtimeController.text.trim()),
        rating: _ratingController.text.trim().isEmpty
            ? null
            : double.tryParse(_ratingController.text.trim()),
        personalRating: _personalRatingController.text.trim().isEmpty
            ? null
            : double.tryParse(_personalRatingController.text.trim()),
        format: _selectedFormat,
        storageLocation: _selectedLocation,
        isWatched: _isWatched,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add movie'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _addMovie,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _directorController,
              decoration: const InputDecoration(
                labelText: 'Director',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _releaseYearController,
                    decoration: const InputDecoration(
                      labelText: 'Release Year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _runtimeController,
                    decoration: const InputDecoration(
                      labelText: 'Runtime (min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ratingController,
                    decoration: const InputDecoration(
                      labelText: 'IMDB Rating',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _personalRatingController,
                    decoration: const InputDecoration(
                      labelText: 'My Rating',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<MovieFormat>(
              initialValue: _selectedFormat,
              decoration: const InputDecoration(
                labelText: 'Format',
                border: OutlineInputBorder(),
              ),
              items: MovieFormat.values.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text(format.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedFormat = value!);
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<StorageLocation>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Storage Location',
                border: OutlineInputBorder(),
              ),
              items: StorageLocation.values.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(_formatLocationName(location.name)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLocation = value!);
              },
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Watched'),
              value: _isWatched,
              onChanged: (value) {
                setState(() => _isWatched = value);
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  String _formatLocationName(String name) {
    return name
        .split(RegExp(r'(?=[A-Z])'))
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}