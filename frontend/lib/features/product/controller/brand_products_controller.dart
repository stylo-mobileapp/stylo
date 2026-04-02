import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/features/search/models/search_filters.dart';
import 'package:frontend/features/search/repository/search_repository.dart';
import 'package:frontend/models/product_summary.dart';

// -----------------------------------------------------------------------------
// BRAND SEARCH STATE
// -----------------------------------------------------------------------------

final brandProductsFiltersProvider =
    StateProvider.family<SearchFilters, String>(
      (ref, brand) => SearchFilters(brands: [brand]),
    );

class BrandProductsState {
  final AsyncValue<List<ProductSummary>> products;
  final bool isLoadingMore;
  final bool hasMore;

  const BrandProductsState({
    required this.products,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  BrandProductsState copyWith({
    AsyncValue<List<ProductSummary>>? products,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return BrandProductsState(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final brandProductsResultsProvider =
    StateNotifierProvider.family<
      BrandProductsController,
      BrandProductsState,
      String
    >((ref, brand) {
      return BrandProductsController(ref, brand);
    });

class BrandProductsController extends StateNotifier<BrandProductsState> {
  final Ref ref;
  final String brand;
  int _page = 0;
  static const int _limit = 20;

  BrandProductsController(this.ref, this.brand)
    : super(const BrandProductsState(products: AsyncValue.data([])));

  Future<void> fetch() async {
    _page = 0;
    state = state.copyWith(
      products: const AsyncValue.loading(),
      hasMore: true,
      isLoadingMore: false,
    );

    final filters = ref.read(brandProductsFiltersProvider(brand));

    final result = await ref
        .read(searchRepositoryProvider)
        .searchProducts('', filters, limit: _limit, offset: 0);

    result.fold(
      (failure) => state = state.copyWith(
        products: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (products) {
        state = state.copyWith(
          products: AsyncValue.data(products),
          hasMore: products.length >= _limit,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.products is! AsyncData) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    _page++;

    final currentProducts = state.products.value!;
    final filters = ref.read(brandProductsFiltersProvider(brand));

    final result = await ref
        .read(searchRepositoryProvider)
        .searchProducts('', filters, limit: _limit, offset: _page * _limit);

    result.fold(
      (failure) {
        _page--;
        state = state.copyWith(isLoadingMore: false);
      },
      (newProducts) {
        state = state.copyWith(
          products: AsyncValue.data([...currentProducts, ...newProducts]),
          hasMore: newProducts.length >= _limit,
          isLoadingMore: false,
        );
      },
    );
  }
}
