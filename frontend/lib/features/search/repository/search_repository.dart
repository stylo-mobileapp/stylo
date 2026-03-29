import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/failure/failure.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/search/models/search_filters.dart';
import 'package:frontend/models/product_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final searchRepositoryProvider = Provider(
  (ref) => SearchRepository(ref.read(supabaseClientProvider)),
);

class SearchRepository {
  final SupabaseClient supabaseClient;

  SearchRepository(this.supabaseClient);

  Future<Either<Failure, List<String>>> getFilterOptions(
    String viewName,
    String columnName,
  ) async {
    try {
      final response = await supabaseClient
          .from(viewName)
          .select(columnName)
          .order('product_count', ascending: false);

      final List<String> options = (response as List)
          .map((row) => row[columnName] as String)
          .toList();
      return right(options);
    } catch (e) {
      return left(Failure("Couldn't load filter options for $viewName."));
    }
  }

  Future<Either<Failure, List<ProductSummary>>> searchProducts(
    String textQuery,
    SearchFilters filters, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> filterBuilder = supabaseClient
          .from('products')
          .select(ProductSummary.selectColumns);

      // Text search
      if (textQuery.trim().isNotEmpty) {
        filterBuilder = filterBuilder.textSearch(
          'text_search',
          textQuery.trim(),
          type: TextSearchType.websearch,
        );
      }

      // Arrays of filters
      if (filters.brands.isNotEmpty) {
        filterBuilder = filterBuilder.inFilter('brand', filters.brands);
      }
      if (filters.categories.isNotEmpty) {
        filterBuilder = filterBuilder.inFilter('category', filters.categories);
      }
      if (filters.genders.isNotEmpty) {
        filterBuilder = filterBuilder.inFilter('gender', filters.genders);
      }
      if (filters.sources.isNotEmpty) {
        filterBuilder = filterBuilder.inFilter('source', filters.sources);
      }

      // Price ranges
      if (filters.minPrice != null) {
        filterBuilder = filterBuilder.gte('price', filters.minPrice!);
      }
      if (filters.maxPrice != null) {
        filterBuilder = filterBuilder.lte('price', filters.maxPrice!);
      }

      if (filters.onlyDiscounted) {
        filterBuilder = filterBuilder.gt('discount_percentage', 0);
      }

      // Sort
      PostgrestTransformBuilder<PostgrestList> transformBuilder;
      switch (filters.sortOption) {
        case SearchSortOption.newest:
          transformBuilder = filterBuilder.order(
            'updated_at',
            ascending: false,
          );
          break;
        case SearchSortOption.priceLowToHigh:
          transformBuilder = filterBuilder.order('price', ascending: true);
          break;
        case SearchSortOption.priceHighToLow:
          transformBuilder = filterBuilder.order('price', ascending: false);
          break;
      }

      // Execute with pagination
      final response = await transformBuilder.range(offset, offset + limit - 1);

      final products = (response as List)
          .map((row) => ProductSummary.fromJson(row as Map<String, dynamic>))
          .toList();

      return right(products);
    } catch (e) {
      return left(Failure("Search failed."));
    }
  }
}
