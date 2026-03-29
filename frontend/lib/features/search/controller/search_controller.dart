import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/search/models/search_filters.dart';
import 'package:frontend/features/search/repository/search_repository.dart';
import 'package:frontend/models/product_summary.dart';

// -----------------------------------------------------------------------------
// HISTORY
// -----------------------------------------------------------------------------

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesController, List<String>>((ref) {
      return RecentSearchesController(ref);
    });

class RecentSearchesController extends StateNotifier<List<String>> {
  final Ref ref;

  RecentSearchesController(this.ref) : super([]) {
    load();
  }

  void load() {
    state = ref.read(sharedPreferencesProvider).getRecentSearches();
  }

  Future<void> add(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    await ref.read(sharedPreferencesProvider).addRecentSearch(cleanQuery);
    load();
  }

  Future<void> remove(String query) async {
    await ref.read(sharedPreferencesProvider).removeRecentSearch(query);
    load();
  }
}

// -----------------------------------------------------------------------------
// FILTER OPTIONS (from Supabase Views)
// -----------------------------------------------------------------------------

final filterBrandsProvider = FutureProvider<List<String>>((ref) async {
  final res = await ref
      .read(searchRepositoryProvider)
      .getFilterOptions('mv_brands', 'name');
  return res.fold((l) => throw l.message, (r) => r);
});

final filterCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final res = await ref
      .read(searchRepositoryProvider)
      .getFilterOptions('mv_categories', 'name');
  return res.fold((l) => throw l.message, (r) => r);
});

final filterGendersProvider = FutureProvider<List<String>>((ref) async {
  final res = await ref
      .read(searchRepositoryProvider)
      .getFilterOptions('mv_genders', 'name');
  return res.fold((l) => throw l.message, (r) => r);
});

final filterSourcesProvider = FutureProvider<List<String>>((ref) async {
  final res = await ref
      .read(searchRepositoryProvider)
      .getFilterOptions('mv_sources', 'name');
  return res.fold((l) => throw l.message, (r) => r);
});

// -----------------------------------------------------------------------------
// SEARCH STATE
// -----------------------------------------------------------------------------

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchFiltersProvider = StateProvider<SearchFilters>(
  (ref) => const SearchFilters(),
);

class SearchState {
  final AsyncValue<List<ProductSummary>> products;
  final bool isLoadingMore;
  final bool hasMore;

  const SearchState({
    required this.products,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  SearchState copyWith({
    AsyncValue<List<ProductSummary>>? products,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return SearchState(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final searchResultsProvider =
    StateNotifierProvider<SearchResultsController, SearchState>((ref) {
      return SearchResultsController(ref);
    });

class SearchResultsController extends StateNotifier<SearchState> {
  final Ref ref;
  int _page = 0;
  static const int _limit = 20;

  SearchResultsController(this.ref)
    : super(const SearchState(products: AsyncValue.data([])));

  Future<void> search() async {
    _page = 0;
    state = state.copyWith(
      products: const AsyncValue.loading(),
      hasMore: true,
      isLoadingMore: false,
    );

    final query = ref.read(searchQueryProvider);
    final filters = ref.read(searchFiltersProvider);

    final result = await ref
        .read(searchRepositoryProvider)
        .searchProducts(query, filters, limit: _limit, offset: 0);

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
    final query = ref.read(searchQueryProvider);
    final filters = ref.read(searchFiltersProvider);

    final result = await ref
        .read(searchRepositoryProvider)
        .searchProducts(query, filters, limit: _limit, offset: _page * _limit);

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
