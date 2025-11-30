/// Priority level for wishlist items
enum WishlistPriority { low, medium, high }

/// Represents a movie the user wants to add to their collection
class WishlistItem {
  final String id;
  final String movieTitle;
  final String? movieId;
  final WishlistPriority priority;
  final String? notes;
  final double? expectedPrice;
  final String? whereToFind;
  final DateTime dateAdded;

  const WishlistItem({
    required this.id,
    required this.movieTitle,
    this.movieId,
    this.priority = WishlistPriority.medium,
    this.notes,
    this.expectedPrice,
    this.whereToFind,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieTitle': movieTitle,
      'movieId': movieId,
      'priority': priority.name,
      'notes': notes,
      'expectedPrice': expectedPrice,
      'whereToFind': whereToFind,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] ?? '',
      movieTitle: map['movieTitle'] ?? '',
      movieId: map['movieId'],
      priority: WishlistPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => WishlistPriority.medium,
      ),
      notes: map['notes'],
      expectedPrice: map['expectedPrice']?.toDouble(),
      whereToFind: map['whereToFind'],
      dateAdded: DateTime.parse(
        map['dateAdded'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  WishlistItem copyWith({
    String? id,
    String? movieTitle,
    String? movieId,
    WishlistPriority? priority,
    String? notes,
    double? expectedPrice,
    String? whereToFind,
    DateTime? dateAdded,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      movieTitle: movieTitle ?? this.movieTitle,
      movieId: movieId ?? this.movieId,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      whereToFind: whereToFind ?? this.whereToFind,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  String toString() => '$movieTitle - ${priority.name} priority';
}

/// Collection of movies the user wants to acquire
class Wishlist {
  final String id;
  final List<WishlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wishlist({
    required this.id,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Wishlist.fromMap(Map<String, dynamic> map) {
    return Wishlist(
      id: map['id'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => WishlistItem.fromMap(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Wishlist copyWith({
    String? id,
    List<WishlistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wishlist(
      id: id ?? this.id,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Wishlist addItem(WishlistItem item) {
    return copyWith(items: [...items, item], updatedAt: DateTime.now());
  }

  Wishlist removeItem(String itemId) {
    return copyWith(
      items: items.where((item) => item.id != itemId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Wishlist updateItem(String itemId, WishlistItem updatedItem) {
    return copyWith(
      items: items
          .map((item) => item.id == itemId ? updatedItem : item)
          .toList(),
      updatedAt: DateTime.now(),
    );
  }

  List<WishlistItem> getItemsByPriority(WishlistPriority priority) =>
      items.where((item) => item.priority == priority).toList();

  int get itemCount => items.length;

  @override
  String toString() => 'Wishlist: $itemCount items';
}
