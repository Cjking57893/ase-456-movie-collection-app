import '../models/wishlist.dart';
import '../repositories/user_repository.dart';

/// Manages user wishlist operations for movies they want to acquire
class WishlistService {
  final UserRepository _userRepository;

  WishlistService({required UserRepository userRepository})
      : _userRepository = userRepository;

  Future<Wishlist?> getUserWishlist(String userId) async {
    final user = await _userRepository.getUser(userId);
    return user?.wishlist;
  }

  Future<void> addWishlistItem({
    required String userId,
    required String movieTitle,
    String? movieId,
    WishlistPriority priority = WishlistPriority.medium,
    String? notes,
    double? expectedPrice,
    String? whereToFind,
  }) async {
    final user = await _userRepository.getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // Check if movie already exists in wishlist
    final isDuplicate = user.wishlist.items.any(
      (item) => item.movieId != null && item.movieId == movieId,
    );

    if (isDuplicate) {
      throw Exception('This movie is already in your wishlist');
    }

    final itemId = DateTime.now().millisecondsSinceEpoch.toString();
    final item = WishlistItem(
      id: itemId,
      movieTitle: movieTitle,
      movieId: movieId,
      priority: priority,
      notes: notes,
      expectedPrice: expectedPrice,
      whereToFind: whereToFind,
      dateAdded: DateTime.now(),
    );

    final updatedUser = user.addToWishlist(item);
    await _userRepository.updateUser(updatedUser);
  }

  Future<void> updateWishlistItem({
    required String userId,
    required String itemId,
    required String movieTitle,
    String? movieId,
    WishlistPriority? priority,
    String? notes,
    double? expectedPrice,
    String? whereToFind,
  }) async {
    final user = await _userRepository.getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    final existingItem = user.wishlist.items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Wishlist item not found'),
    );

    final updatedItem = existingItem.copyWith(
      movieTitle: movieTitle,
      movieId: movieId,
      priority: priority,
      notes: notes,
      expectedPrice: expectedPrice,
      whereToFind: whereToFind,
    );

    final updatedWishlist = user.wishlist.updateItem(itemId, updatedItem);
    final updatedUser = user.updateWishlist(updatedWishlist);
    await _userRepository.updateUser(updatedUser);
  }

  Future<void> deleteWishlistItem(String userId, String itemId) async {
    final user = await _userRepository.getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    final updatedUser = user.removeFromWishlist(itemId);
    await _userRepository.updateUser(updatedUser);
  }

  Future<List<WishlistItem>> getWishlistItemsByPriority(
    String userId,
    WishlistPriority priority,
  ) async {
    final wishlist = await getUserWishlist(userId);
    return wishlist?.getItemsByPriority(priority) ?? [];
  }
}
