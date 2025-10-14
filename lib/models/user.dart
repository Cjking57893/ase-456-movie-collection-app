import 'wishlist.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> movieIds;
  final Wishlist wishlist;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.movieIds = const [],
    required this.wishlist,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'movieIds': movieIds,
      'wishlist': wishlist.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      movieIds: List<String>.from(map['movieIds'] ?? []),
      wishlist: map['wishlist'] != null
          ? Wishlist.fromMap(map['wishlist'])
          : Wishlist(
              id: 'wishlist_${map['id'] ?? ''}',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? movieIds,
    Wishlist? wishlist,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      movieIds: movieIds ?? this.movieIds,
      wishlist: wishlist ?? this.wishlist,
    );
  }

  User addMovie(String movieId) {
    if (movieIds.contains(movieId)) return this;
    return copyWith(
      movieIds: [...movieIds, movieId],
      updatedAt: DateTime.now(),
    );
  }

  User removeMovie(String movieId) {
    return copyWith(
      movieIds: movieIds.where((id) => id != movieId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  bool hasMovie(String movieId) => movieIds.contains(movieId);

  User updateWishlist(Wishlist newWishlist) {
    return copyWith(wishlist: newWishlist, updatedAt: DateTime.now());
  }

  User addToWishlist(WishlistItem item) {
    return copyWith(
      wishlist: wishlist.addItem(item),
      updatedAt: DateTime.now(),
    );
  }

  User removeFromWishlist(String itemId) {
    return copyWith(
      wishlist: wishlist.removeItem(itemId),
      updatedAt: DateTime.now(),
    );
  }

  int get movieCount => movieIds.length;
  int get wishlistCount => wishlist.itemCount;

  @override
  String toString() => '$displayName ($email)';
}
