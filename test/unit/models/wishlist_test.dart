import 'package:flutter_test/flutter_test.dart';
import 'package:movie_collection_app/models/wishlist.dart';

void main() {
  group('WishlistItem Model', () {
    late WishlistItem testItem;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testItem = WishlistItem(
        id: 'item-123',
        movieTitle: 'Inception',
        movieId: 'tmdb-12345',
        priority: WishlistPriority.high,
        notes: 'Must buy!',
        expectedPrice: 19.99,
        whereToFind: 'Amazon',
        dateAdded: testDate,
      );
    });

    test('creates WishlistItem with all properties', () {
      expect(testItem.id, 'item-123');
      expect(testItem.movieTitle, 'Inception');
      expect(testItem.movieId, 'tmdb-12345');
      expect(testItem.priority, WishlistPriority.high);
      expect(testItem.notes, 'Must buy!');
      expect(testItem.expectedPrice, 19.99);
      expect(testItem.whereToFind, 'Amazon');
    });

    test('toMap converts WishlistItem to Map correctly', () {
      final map = testItem.toMap();

      expect(map['id'], 'item-123');
      expect(map['movieTitle'], 'Inception');
      expect(map['priority'], 'high');
      expect(map['expectedPrice'], 19.99);
    });

    test('fromMap creates WishlistItem from Map correctly', () {
      final map = testItem.toMap();
      final itemFromMap = WishlistItem.fromMap(map);

      expect(itemFromMap.id, testItem.id);
      expect(itemFromMap.movieTitle, testItem.movieTitle);
      expect(itemFromMap.priority, testItem.priority);
    });

    test('copyWith creates new WishlistItem with updated values', () {
      final updatedItem = testItem.copyWith(
        priority: WishlistPriority.low,
        expectedPrice: 14.99,
      );

      expect(updatedItem.priority, WishlistPriority.low);
      expect(updatedItem.expectedPrice, 14.99);
      expect(updatedItem.movieTitle, testItem.movieTitle); // Unchanged
    });

    test('toString returns formatted string', () {
      final result = testItem.toString();
      expect(result, 'Inception - high priority');
    });

    test('creates WishlistItem with defaults', () {
      final minimalItem = WishlistItem(
        id: 'item-min',
        movieTitle: 'Minimal Item',
        dateAdded: testDate,
      );

      expect(minimalItem.priority, WishlistPriority.medium);
      expect(minimalItem.movieId, isNull);
      expect(minimalItem.notes, isNull);
      expect(minimalItem.expectedPrice, isNull);
    });
  });

  group('Wishlist Model', () {
    late Wishlist testWishlist;
    late DateTime testDate;
    late WishlistItem item1;
    late WishlistItem item2;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      item1 = WishlistItem(
        id: 'item1',
        movieTitle: 'Inception',
        priority: WishlistPriority.high,
        dateAdded: testDate,
      );
      item2 = WishlistItem(
        id: 'item2',
        movieTitle: 'The Matrix',
        priority: WishlistPriority.medium,
        dateAdded: testDate,
      );
      testWishlist = Wishlist(
        id: 'wishlist-123',
        items: [item1, item2],
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    test('creates Wishlist with all properties', () {
      expect(testWishlist.id, 'wishlist-123');
      expect(testWishlist.items.length, 2);
      expect(testWishlist.itemCount, 2);
    });

    test('toMap converts Wishlist to Map correctly', () {
      final map = testWishlist.toMap();

      expect(map['id'], 'wishlist-123');
      expect(map['items'], isList);
      expect((map['items'] as List).length, 2);
    });

    test('fromMap creates Wishlist from Map correctly', () {
      final map = testWishlist.toMap();
      final wishlistFromMap = Wishlist.fromMap(map);

      expect(wishlistFromMap.id, testWishlist.id);
      expect(wishlistFromMap.items.length, 2);
    });

    test('addItem adds new item to wishlist', () {
      final newItem = WishlistItem(
        id: 'item3',
        movieTitle: 'Interstellar',
        dateAdded: testDate,
      );

      final updatedWishlist = testWishlist.addItem(newItem);

      expect(updatedWishlist.items.length, 3);
      expect(updatedWishlist.items.last.movieTitle, 'Interstellar');
    });

    test('removeItem removes item from wishlist', () {
      final updatedWishlist = testWishlist.removeItem('item1');

      expect(updatedWishlist.items.length, 1);
      expect(updatedWishlist.items.first.id, 'item2');
    });

    test('updateItem updates existing item', () {
      final updatedItem = item1.copyWith(priority: WishlistPriority.low);
      final updatedWishlist = testWishlist.updateItem('item1', updatedItem);

      final item = updatedWishlist.items.firstWhere((i) => i.id == 'item1');
      expect(item.priority, WishlistPriority.low);
    });

    test('getItemsByPriority filters items correctly', () {
      final highPriorityItems = testWishlist.getItemsByPriority(
        WishlistPriority.high,
      );

      expect(highPriorityItems.length, 1);
      expect(highPriorityItems.first.movieTitle, 'Inception');
    });

    test('itemCount returns correct count', () {
      expect(testWishlist.itemCount, 2);

      final emptyWishlist = testWishlist.copyWith(items: []);
      expect(emptyWishlist.itemCount, 0);
    });

    test('toString returns formatted string', () {
      final result = testWishlist.toString();
      expect(result, 'Wishlist: 2 items');
    });

    test('copyWith creates new Wishlist with updated values', () {
      final updatedWishlist = testWishlist.copyWith(
        items: [item1],
      );

      expect(updatedWishlist.items.length, 1);
      expect(updatedWishlist.id, testWishlist.id); // Unchanged
    });

    test('creates empty Wishlist', () {
      final emptyWishlist = Wishlist(
        id: 'empty',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(emptyWishlist.items, isEmpty);
      expect(emptyWishlist.itemCount, 0);
    });
  });

  group('WishlistPriority Enum', () {
    test('has correct values', () {
      expect(WishlistPriority.values.length, 3);
      expect(WishlistPriority.values, [
        WishlistPriority.low,
        WishlistPriority.medium,
        WishlistPriority.high,
      ]);
    });
  });
}
