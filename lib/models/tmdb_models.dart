class TmdbMovie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final double voteAverage;
  final int voteCount;
  final bool adult;
  final String originalLanguage;
  final String originalTitle;
  final double popularity;
  final bool video;

  TmdbMovie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.genreIds = const [],
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.adult = false,
    this.originalLanguage = '',
    this.originalTitle = '',
    this.popularity = 0.0,
    this.video = false,
  });

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : [],
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      video: json['video'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'adult': adult,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'popularity': popularity,
      'video': video,
    };
  }

  int? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    try {
      return DateTime.parse(releaseDate!).year;
    } catch (e) {
      return null;
    }
  }
}

class TmdbMovieDetails extends TmdbMovie {
  final int? runtime;
  final String? status;
  final String? tagline;
  final List<TmdbGenre> genres;
  final List<TmdbCastMember> cast;
  final List<TmdbCrewMember> crew;
  final int budget;
  final int revenue;
  final String? imdbId;
  final String? homepage;

  TmdbMovieDetails({
    required super.id,
    required super.title,
    super.overview,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    super.genreIds,
    super.voteAverage,
    super.voteCount,
    super.adult,
    super.originalLanguage,
    super.originalTitle,
    super.popularity,
    super.video,
    this.runtime,
    this.status,
    this.tagline,
    this.genres = const [],
    this.cast = const [],
    this.crew = const [],
    this.budget = 0,
    this.revenue = 0,
    this.imdbId,
    this.homepage,
  });

  factory TmdbMovieDetails.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : [],
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      video: json['video'] ?? false,
      runtime: json['runtime'],
      status: json['status'],
      tagline: json['tagline'],
      genres: json['genres'] != null
          ? (json['genres'] as List).map((g) => TmdbGenre.fromJson(g)).toList()
          : [],
      cast: json['credits'] != null && json['credits']['cast'] != null
          ? (json['credits']['cast'] as List)
                .map((c) => TmdbCastMember.fromJson(c))
                .toList()
          : [],
      crew: json['credits'] != null && json['credits']['crew'] != null
          ? (json['credits']['crew'] as List)
                .map((c) => TmdbCrewMember.fromJson(c))
                .toList()
          : [],
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      imdbId: json['imdb_id'],
      homepage: json['homepage'],
    );
  }

  String? get director {
    try {
      final director = crew.firstWhere((member) => member.job == 'Director');
      return director.name;
    } catch (e) {
      return null;
    }
  }

  List<String> get mainActors {
    return cast.take(5).map((actor) => actor.name).toList();
  }

  List<String> get genreNames {
    return genres.map((genre) => genre.name).toList();
  }
}

class TmdbGenre {
  final int id;
  final String name;

  TmdbGenre({required this.id, required this.name});

  factory TmdbGenre.fromJson(Map<String, dynamic> json) {
    return TmdbGenre(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class TmdbCastMember {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int order;

  TmdbCastMember({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order = 0,
  });

  factory TmdbCastMember.fromJson(Map<String, dynamic> json) {
    return TmdbCastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'],
      profilePath: json['profile_path'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profile_path': profilePath,
      'order': order,
    };
  }
}

class TmdbCrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  TmdbCrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory TmdbCrewMember.fromJson(Map<String, dynamic> json) {
    return TmdbCrewMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'job': job,
      'department': department,
      'profile_path': profilePath,
    };
  }
}

class TmdbSearchResponse {
  final int page;
  final List<TmdbMovie> results;
  final int totalPages;
  final int totalResults;

  TmdbSearchResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TmdbSearchResponse.fromJson(Map<String, dynamic> json) {
    return TmdbSearchResponse(
      page: json['page'] ?? 1,
      results: json['results'] != null
          ? (json['results'] as List)
                .map((movie) => TmdbMovie.fromJson(movie))
                .toList()
          : [],
      totalPages: json['total_pages'] ?? 1,
      totalResults: json['total_results'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'results': results.map((movie) => movie.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}
