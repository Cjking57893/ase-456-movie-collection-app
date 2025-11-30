import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:movie_collection_app/services/wishlist_service.dart';
import 'package:movie_collection_app/repositories/user_repository.dart';
import 'package:movie_collection_app/models/user.dart';
import 'package:movie_collection_app/models/wishlist.dart';

import 'wishlist_service_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  group('WishlistService', () {
    late WishlistService wishlistService;
    late MockUserRepository mockUserRepository;
    late User testUser;
    late DateTime testDate;

    setUp(() {
      mockUserRepository = MockUserRepository();
      wishlistService = WishlistService(userRepository: mockUserRepository);
      testDate = DateTime(2024, 1, 1);
      
      testUser = User(
        id: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: testDate,
        updatedAt: testDate,
        wishlist: Wishlist(
          id: 'wishlist-123',
          createdAt: testDate,
          updatedAt: testDate,
          items: [],
        ),
      );
    });

    group('getUserWishlist', () {
      test('returns user wishlist', () async {
        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => testUser);

        final wishlist = await wishlistService.getUserWishlist('user-123');

        expect(wishlist, isNotNull);
        expect(wishlist!.id, 'wishlist-123');
        verify(mockUserRepository.getUser('user-123')).called(1);
      });

      test('returns null when user not found', () async {
        when(mockUserRepository.getUser('user-999'))
            .thenAnswer((_) async => null);

        final wishlist = await wishlistService.getUserWishlist('user-999');

        expect(wishlist, isNull);
      });
    });

    group('addWishlistItem', () {
      test('adds item to wishlist', () async {
        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => testUser);
        when(mockUserRepository.updateUser(any))
            .thenAnswer((_) async => Future.value());

        await wishlistService.addWishlistItem(
          userId: 'user-123',
          movieTitle: 'Inception',
          movieId: 'tmdb-12345',
          priority: WishlistPriority.high,
          notes: 'Must buy!',
          expectedPrice: 19.99,
          whereToFind: 'Amazon',
        );

        verify(mockUserRepository.getUser('user-123')).called(1);
        verify(mockUserRepository.updateUser(any)).called(1);
      });

      test('throws exception when user not found', () async {
        when(mockUserRepository.getUser('user-999'))
            .thenAnswer((_) async => null);

        expect(
          () => wishlistService.addWishlistItem(
            userId: 'user-999',
            movieTitle: 'Inception',
          ),
          throwsA(isA<Exception>()),
        );

        verifyNever(mockUserRepository.updateUser(any));
      });

      test('throws exception when movie already in wishlist', () async {
        final item = WishlistItem(
          id: 'item-1',
          movieTitle: 'Inception',
          movieId: 'tmdb-12345',
          dateAdded: testDate,
        );
        
        final userWithWishlist = testUser.copyWith(
          wishlist: testUser.wishlist.addItem(item),
        );

        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => userWithWishlist);

        expect(
          () => wishlistService.addWishlistItem(
            userId: 'user-123',
            movieTitle: 'Inception',
            movieId: 'tmdb-12345',
          ),
          throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('already in your wishlist'))),
        );

        verifyNever(mockUserRepository.updateUser(any));
      });
    });

    group('updateWishlistItem', () {
      test('updates existing wishlist item', () async {
        final item = WishlistItem(
          id: 'item-1',
          movieTitle: 'Inception',
          priority: WishlistPriority.medium,
          dateAdded: testDate,
        );
        
        final userWithWishlist = testUser.copyWith(
          wishlist: testUser.wishlist.addItem(item),
        );

        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => userWithWishlist);
        when(mockUserRepository.updateUser(any))
            .thenAnswer((_) async => Future.value());

        await wishlistService.updateWishlistItem(
          userId: 'user-123',
          itemId: 'item-1',
          movieTitle: 'Inception',
          priority: WishlistPriority.high,
        );

        verify(mockUserRepository.updateUser(any)).called(1);
      });

      test('throws exception when item not found', () async {
        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => testUser);

        expect(
          () => wishlistService.updateWishlistItem(
            userId: 'user-123',
            itemId: 'nonexistent',
            movieTitle: 'Test',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteWishlistItem', () {
      test('removes item from wishlist', () async {
        final item = WishlistItem(
          id: 'item-1',
          movieTitle: 'Inception',
          dateAdded: testDate,
        );
        
        final userWithWishlist = testUser.copyWith(
          wishlist: testUser.wishlist.addItem(item),
        );

        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => userWithWishlist);
        when(mockUserRepository.updateUser(any))
            .thenAnswer((_) async => Future.value());

        await wishlistService.deleteWishlistItem('user-123', 'item-1');

        verify(mockUserRepository.updateUser(any)).called(1);
      });

      test('throws exception when user not found', () async {
        when(mockUserRepository.getUser('user-999'))
            .thenAnswer((_) async => null);

        expect(
          () => wishlistService.deleteWishlistItem('user-999', 'item-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getWishlistItemsByPriority', () {
      test('returns items filtered by priority', () async {
        final item1 = WishlistItem(
          id: 'item-1',
          movieTitle: 'Inception',
          priority: WishlistPriority.high,
          dateAdded: testDate,
        );
        final item2 = WishlistItem(
          id: 'item-2',
          movieTitle: 'The Matrix',
          priority: WishlistPriority.medium,
          dateAdded: testDate,
        );
        
        final wishlistWithItems = testUser.wishlist
            .addItem(item1)
            .addItem(item2);
        
        final userWithWishlist = testUser.copyWith(
          wishlist: wishlistWithItems,
        );

        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => userWithWishlist);

        final highPriorityItems = await wishlistService.getWishlistItemsByPriority(
          'user-123',
          WishlistPriority.high,
        );

        expect(highPriorityItems.length, 1);
        expect(highPriorityItems.first.movieTitle, 'Inception');
      });

      test('returns empty list when no items match priority', () async {
        when(mockUserRepository.getUser('user-123'))
            .thenAnswer((_) async => testUser);

        final items = await wishlistService.getWishlistItemsByPriority(
          'user-123',
          WishlistPriority.high,
        );

        expect(items, isEmpty);
      });
    });
  });
}
