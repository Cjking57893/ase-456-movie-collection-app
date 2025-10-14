class Movie {
  final String id;
  final String title;
  final String? description;
  final String? genre;
  final int? year;
  final double? rating;
  final String? posterUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.genre,
    this.year,
    this.rating,
    this.posterUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Movie to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genre': genre,
      'year': year,
      'rating': rating,
      'posterUrl': posterUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Movie from Firestore Map
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      genre: map['genre'],
      year: map['year'],
      rating: map['rating']?.toDouble(),
      posterUrl: map['posterUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a copy with updated fields
  Movie copyWith({
    String? id,
    String? title,
    String? description,
    String? genre,
    int? year,
    double? rating,
    String? posterUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      posterUrl: posterUrl ?? this.posterUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, genre: $genre, year: $year, rating: $rating}';
  }
}