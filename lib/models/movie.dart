enum MovieFormat { dvd, bluray }

enum StorageLocation {
  livingRoom,
  bedroom,
  basement,
  attic,
  office,
  storage,
  other,
}

class Movie {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final List<String> genres;
  final int? releaseYear;
  final String? director;
  final List<String> actors;
  final int? runtime;
  final double? rating;
  final double? personalRating;
  final String? posterUrl;
  final MovieFormat format;
  final StorageLocation storageLocation;
  final String? specificLocation;
  final bool isWatched;
  final DateTime? watchedDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Movie({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.genres = const [],
    this.releaseYear,
    this.director,
    this.actors = const [],
    this.runtime,
    this.rating,
    this.personalRating,
    this.posterUrl,
    this.format = MovieFormat.dvd,
    this.storageLocation = StorageLocation.livingRoom,
    this.specificLocation,
    this.isWatched = false,
    this.watchedDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'genres': genres,
      'releaseYear': releaseYear,
      'director': director,
      'actors': actors,
      'runtime': runtime,
      'rating': rating,
      'personalRating': personalRating,
      'posterUrl': posterUrl,
      'format': format.name,
      'storageLocation': storageLocation.name,
      'specificLocation': specificLocation,
      'isWatched': isWatched,
      'watchedDate': watchedDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      genres: List<String>.from(map['genres'] ?? []),
      releaseYear: map['releaseYear'],
      director: map['director'],
      actors: List<String>.from(map['actors'] ?? []),
      runtime: map['runtime'],
      rating: map['rating']?.toDouble(),
      personalRating: map['personalRating']?.toDouble(),
      posterUrl: map['posterUrl'],
      format: MovieFormat.values.firstWhere(
        (e) => e.name == map['format'],
        orElse: () => MovieFormat.dvd,
      ),
      storageLocation: StorageLocation.values.firstWhere(
        (e) => e.name == map['storageLocation'],
        orElse: () => StorageLocation.livingRoom,
      ),
      specificLocation: map['specificLocation'],
      isWatched: map['isWatched'] ?? false,
      watchedDate: map['watchedDate'] != null
          ? DateTime.parse(map['watchedDate'])
          : null,
      notes: map['notes'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Movie copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? genres,
    int? releaseYear,
    String? director,
    List<String>? actors,
    int? runtime,
    double? rating,
    double? personalRating,
    String? posterUrl,
    MovieFormat? format,
    StorageLocation? storageLocation,
    String? specificLocation,
    bool? isWatched,
    DateTime? watchedDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Movie(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      releaseYear: releaseYear ?? this.releaseYear,
      director: director ?? this.director,
      actors: actors ?? this.actors,
      runtime: runtime ?? this.runtime,
      rating: rating ?? this.rating,
      personalRating: personalRating ?? this.personalRating,
      posterUrl: posterUrl ?? this.posterUrl,
      format: format ?? this.format,
      storageLocation: storageLocation ?? this.storageLocation,
      specificLocation: specificLocation ?? this.specificLocation,
      isWatched: isWatched ?? this.isWatched,
      watchedDate: watchedDate ?? this.watchedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Movie: $title ($releaseYear)';
}
