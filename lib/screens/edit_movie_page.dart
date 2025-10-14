import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../models/movie.dart';

class EditMoviePage extends StatefulWidget {
  final Movie movie;
  
  const EditMoviePage({super.key, required this.movie});

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _directorController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _releaseYearController;
  late final TextEditingController _runtimeController;
  late final TextEditingController _ratingController;
  late final TextEditingController _personalRatingController;
  late final TextEditingController _notesController;
  
  final _movieService = ServiceLocator().movieService;
  final _authService = ServiceLocator().authService;

  late MovieFormat _selectedFormat;
  late StorageLocation _selectedLocation;
  late bool _isWatched;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _directorController = TextEditingController(text: widget.movie.director ?? '');
    _descriptionController = TextEditingController(text: widget.movie.description ?? '');
    _releaseYearController = TextEditingController(text: widget.movie.releaseYear?.toString() ?? '');
    _runtimeController = TextEditingController(text: widget.movie.runtime?.toString() ?? '');
    _ratingController = TextEditingController(text: widget.movie.rating?.toString() ?? '');
    _personalRatingController = TextEditingController(text: widget.movie.personalRating?.toString() ?? '');
    _notesController = TextEditingController(text: widget.movie.notes ?? '');
    
    _selectedFormat = widget.movie.format;
    _selectedLocation = widget.movie.storageLocation;
    _isWatched = widget.movie.isWatched;
  }

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

  Future<void> _updateMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _movieService.updateMovie(
        movieId: widget.movie.id,
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        genres: widget.movie.genres,
        releaseYear: _releaseYearController.text.trim().isEmpty
            ? null
            : int.tryParse(_releaseYearController.text.trim()),
        director: _directorController.text.trim().isEmpty
            ? null
            : _directorController.text.trim(),
        actors: widget.movie.actors,
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
          const SnackBar(content: Text('Movie updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update movie'),
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
        title: const Text('Edit Movie'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateMovie,
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