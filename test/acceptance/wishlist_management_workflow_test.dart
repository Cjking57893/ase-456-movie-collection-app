import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

/// Acceptance Test: Wishlist Management Workflow
/// 
/// Business Requirements Verified:
/// - Users can maintain a wishlist of movies they want to acquire
/// - Wishlist items have title, priority, notes, and expected price
/// - Items can be filtered by priority (high, medium, low)
/// - Users can track where to find movies and expected prices
/// - Wishlist operates independently from movie collection
/// - Wishlist items can be added, updated, and removed
void main() {
  group('Acceptance: Wishlist Workflow', () {
    test('User can add items to their wishlist', () {
      // GIVEN: A user with empty wishlist
      final now = DateTime.now();
      var user = User(
        id: 'user_123',
        email: 'wishlist@example.com',
        displayName: 'Wishlist User',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(
          id: 'wishlist_123',
          createdAt: now,
          updatedAt: now,
          items: [],
        ),
      );

      expect(user.wishlist.itemCount, 0);

      // WHEN: User adds a movie to wishlist
      final item = WishlistItem(
        id: 'item_1',
        movieTitle: 'The Godfather',
        priority: WishlistPriority.high,
        notes: 'Classic must-have for collection',
        expectedPrice: 19.99,
        whereToFind: 'Amazon, Best Buy',
        dateAdded: now,
      );

      user = user.addToWishlist(item);

      // THEN: Item is added to wishlist
      expect(user.wishlist.itemCount, 1);
      expect(user.wishlist.items.first.movieTitle, 'The Godfather');
      expect(user.wishlist.items.first.priority, WishlistPriority.high);
      expect(user.wishlist.items.first.expectedPrice, 19.99);
    });

    test('Wishlist items can have different priorities', () {
      // GIVEN: A wishlist with various priority items
      final now = DateTime.now();
      final highPriority = WishlistItem(
        id: 'item_h',
        movieTitle: 'High Priority Movie',
        priority: WishlistPriority.high,
        dateAdded: now,
      );

      final mediumPriority = WishlistItem(
        id: 'item_m',
        movieTitle: 'Medium Priority Movie',
        priority: WishlistPriority.medium,
        dateAdded: now,
      );

      final lowPriority = WishlistItem(
        id: 'item_l',
        movieTitle: 'Low Priority Movie',
        priority: WishlistPriority.low,
        dateAdded: now,
      );

      final wishlist = Wishlist(
        id: 'wishlist_priority',
        createdAt: now,
        updatedAt: now,
        items: [highPriority, mediumPriority, lowPriority],
      );

      // WHEN: Filtering by priority
      final highItems = wishlist.getItemsByPriority(WishlistPriority.high);
      final mediumItems = wishlist.getItemsByPriority(WishlistPriority.medium);
      final lowItems = wishlist.getItemsByPriority(WishlistPriority.low);

      // THEN: Filtering works correctly
      expect(highItems.length, 1);
      expect(highItems.first.movieTitle, 'High Priority Movie');
      expect(mediumItems.length, 1);
      expect(mediumItems.first.movieTitle, 'Medium Priority Movie');
      expect(lowItems.length, 1);
      expect(lowItems.first.movieTitle, 'Low Priority Movie');
    });

    test('Wishlist items track purchase planning information', () {
      // GIVEN: A wishlist item with detailed planning info
      final now = DateTime.now();
      final item = WishlistItem(
        id: 'item_detailed',
        movieTitle: 'Blade Runner 2049',
        priority: WishlistPriority.high,
        notes: 'Wait for 4K UHD release, check for director\'s cut',
        expectedPrice: 29.99,
        whereToFind: 'Zavvi, Amazon UK',
        dateAdded: now,
      );

      // THEN: All planning information is stored
      expect(item.movieTitle, 'Blade Runner 2049');
      expect(item.expectedPrice, 29.99);
      expect(item.whereToFind, 'Zavvi, Amazon UK');
      expect(item.notes, contains('4K UHD'));
      expect(item.dateAdded, now);
    });

    test('User can update wishlist item details', () {
      // GIVEN: A wishlist with an item
      final now = DateTime.now();
      var wishlist = Wishlist(
        id: 'wishlist_update',
        createdAt: now,
        updatedAt: now,
        items: [
          WishlistItem(
            id: 'item_update',
            movieTitle: 'Inception',
            priority: WishlistPriority.low,
            notes: 'Maybe later',
            dateAdded: now,
          ),
        ],
      );

      // WHEN: User updates the item priority and notes
      final updatedItem = wishlist.items.first.copyWith(
        priority: WishlistPriority.high,
        notes: 'On sale this week! Must buy',
        expectedPrice: 14.99,
      );

      wishlist = wishlist.updateItem('item_update', updatedItem);

      // THEN: Item is updated
      final item = wishlist.items.first;
      expect(item.priority, WishlistPriority.high);
      expect(item.notes, contains('On sale'));
      expect(item.expectedPrice, 14.99);
    });

    test('User can remove items from wishlist', () {
      // GIVEN: A wishlist with multiple items
      final now = DateTime.now();
      var user = User(
        id: 'user_remove',
        email: 'remove@example.com',
        displayName: 'Remove Test',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(
          id: 'wishlist_remove',
          createdAt: now,
          updatedAt: now,
          items: [
            WishlistItem(
              id: 'item_1',
              movieTitle: 'Movie A',
              priority: WishlistPriority.high,
              dateAdded: now,
            ),
            WishlistItem(
              id: 'item_2',
              movieTitle: 'Movie B',
              priority: WishlistPriority.medium,
              dateAdded: now,
            ),
          ],
        ),
      );

      expect(user.wishlist.itemCount, 2);

      // WHEN: User removes an item (after purchasing)
      user = user.removeFromWishlist('item_1');

      // THEN: Item is removed
      expect(user.wishlist.itemCount, 1);
      expect(user.wishlist.items.first.movieTitle, 'Movie B');
    });

    test('Wishlist operates independently from movie collection', () {
      // GIVEN: A user with both collection and wishlist
      final now = DateTime.now();
      var user = User(
        id: 'user_independent',
        email: 'independent@example.com',
        displayName: 'Independent Test',
        createdAt: now,
        updatedAt: now,
        movieIds: ['owned_movie_1', 'owned_movie_2'],
        wishlist: Wishlist(
          id: 'wishlist_ind',
          createdAt: now,
          updatedAt: now,
          items: [
            WishlistItem(
              id: 'wish_1',
              movieTitle: 'Wanted Movie',
              priority: WishlistPriority.high,
              dateAdded: now,
            ),
          ],
        ),
      );

      expect(user.movieCount, 2);
      expect(user.wishlist.itemCount, 1);

      // WHEN: Adding to collection
      user = user.addMovie('owned_movie_3');

      // THEN: Wishlist is unaffected
      expect(user.movieCount, 3);
      expect(user.wishlist.itemCount, 1);

      // WHEN: Adding to wishlist
      user = user.addToWishlist(WishlistItem(
        id: 'wish_2',
        movieTitle: 'Another Want',
        priority: WishlistPriority.medium,
        dateAdded: now,
      ));

      // THEN: Collection is unaffected
      expect(user.movieCount, 3);
      expect(user.wishlist.itemCount, 2);
    });

    test('Complete wishlist workflow from planning to purchase', () {
      // GIVEN: A user planning their purchases
      final now = DateTime.now();
      var user = User(
        id: 'workflow_user',
        email: 'workflow@example.com',
        displayName: 'Workflow Test',
        createdAt: now,
        updatedAt: now,
        movieIds: [],
        wishlist: Wishlist(
          id: 'wishlist_workflow',
          createdAt: now,
          updatedAt: now,
          items: [],
        ),
      );

      // WHEN: User adds movies they want
      user = user.addToWishlist(WishlistItem(
        id: 'w1',
        movieTitle: 'The Matrix',
        priority: WishlistPriority.high,
        expectedPrice: 24.99,
        whereToFind: 'Amazon',
        notes: 'Wait for sale',
        dateAdded: now,
      ));

      user = user.addToWishlist(WishlistItem(
        id: 'w2',
        movieTitle: 'Inception',
        priority: WishlistPriority.medium,
        expectedPrice: 19.99,
        dateAdded: now,
      ));

      user = user.addToWishlist(WishlistItem(
        id: 'w3',
        movieTitle: 'Interstellar',
        priority: WishlistPriority.low,
        dateAdded: now,
      ));

      // THEN: Wishlist has all items
      expect(user.wishlist.itemCount, 3);

      // WHEN: User checks high priority items
      final highPriority = user.wishlist.getItemsByPriority(WishlistPriority.high);

      // THEN: Only high priority items returned
      expect(highPriority.length, 1);
      expect(highPriority.first.movieTitle, 'The Matrix');

      // WHEN: User finds a sale and updates priority
      var updatedWishlist = user.wishlist.updateItem(
        'w2',
        user.wishlist.items.firstWhere((i) => i.movieTitle == 'Inception').copyWith(
          priority: WishlistPriority.high,
          notes: 'Found on sale!',
          expectedPrice: 12.99,
        ),
      );

      user = user.copyWith(wishlist: updatedWishlist);

      // THEN: Priority is updated
      final highPriorityNow = user.wishlist.getItemsByPriority(WishlistPriority.high);
      expect(highPriorityNow.length, 2);

      // WHEN: User purchases a movie
      user = user.addMovie('movie_matrix'); // Added to collection
      user = user.removeFromWishlist('w1'); // Removed from wishlist

      // THEN: Movie is in collection, not wishlist
      expect(user.movieCount, 1);
      expect(user.wishlist.itemCount, 2);
      expect(user.hasMovie('movie_matrix'), true);
    });

    test('Wishlist serialization preserves all data', () {
      // GIVEN: A wishlist with complete data
      final now = DateTime.now();
      final wishlist = Wishlist(
        id: 'wishlist_serialize',
        createdAt: now,
        updatedAt: now,
        items: [
          WishlistItem(
            id: 'item_serialize',
            movieTitle: 'Test Movie',
            movieId: 'movie_123',
            priority: WishlistPriority.high,
            notes: 'Important notes',
            expectedPrice: 29.99,
            whereToFind: 'Amazon',
            dateAdded: now,
          ),
        ],
      );

      // WHEN: Serializing to Map
      final map = wishlist.toMap();

      // THEN: Map contains all data
      expect(map['id'], wishlist.id);
      expect(map['items'], isNotNull);
      expect(map['items'], isList);

      // WHEN: Deserializing back
      final deserialized = Wishlist.fromMap(map);

      // THEN: Wishlist is reconstructed
      expect(deserialized.id, wishlist.id);
      expect(deserialized.items.length, wishlist.items.length);
      expect(deserialized.items.first.movieTitle, 'Test Movie');
      expect(deserialized.items.first.priority, WishlistPriority.high);
      expect(deserialized.items.first.expectedPrice, 29.99);
    });
  });
}
