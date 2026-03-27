import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/wishlist/repository/wishlist_repository.dart';
import 'package:frontend/models/product_summary.dart';

enum WishlistSortOption { lastSaved, priceHighToLow, priceLowToHigh }

final wishlistSortProvider = StateProvider<WishlistSortOption>(
  (ref) => WishlistSortOption.lastSaved,
);

final sortedWishlistProvider = Provider<AsyncValue<List<ProductSummary>>>((
  ref,
) {
  final wishlistAsyncValue = ref.watch(wishlistControllerProvider);
  final sortOption = ref.watch(wishlistSortProvider);

  return wishlistAsyncValue.whenData((products) {
    final sorted = List<ProductSummary>.from(products);
    switch (sortOption) {
      case WishlistSortOption.lastSaved:
        break;
      case WishlistSortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case WishlistSortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
    return sorted;
  });
});

final wishlistControllerProvider =
    StateNotifierProvider<WishlistController, AsyncValue<List<ProductSummary>>>(
      (ref) => WishlistController(ref.read(wishlistRepositoryProvider), ref),
    );

class WishlistController
    extends StateNotifier<AsyncValue<List<ProductSummary>>> {
  final WishlistRepository wishlistRepository;
  final Ref ref;

  WishlistController(this.wishlistRepository, this.ref)
    : super(const AsyncValue.loading()) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final result = await wishlistRepository.getWishlistProducts(userId);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (products) => state = AsyncValue.data(products),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addProduct(ProductSummary product) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;

    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data([product, ...state.value!]);
    }

    final result = await wishlistRepository.addProductToWishlist(
      userId,
      product.id,
    );
    result.fold(
      (failure) {
        // Revert on failure
        state = previousState;
      },
      (_) {}, // Success, keep optimistic state
    );
  }

  Future<void> removeProduct(String productId) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;

    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((p) => p.id != productId).toList(),
      );
    }

    final result = await wishlistRepository.removeProductFromWishlist(
      userId,
      productId,
    );
    result.fold((failure) {
      // Revert on failure
      state = previousState;
    }, (_) {});
  }
}
