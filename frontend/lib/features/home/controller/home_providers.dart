import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/home/repository/home_repository.dart';
import 'package:frontend/models/product_summary.dart';

final recentlyViewedProductsProvider = FutureProvider<List<ProductSummary>>((
  ref,
) async {
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return [];

  final result = await ref
      .read(homeRepositoryProvider)
      .getRecentlyViewed(userId);
  return result.fold((failure) => throw failure, (products) => products);
});

final discountedProductsProvider = FutureProvider<List<ProductSummary>>((
  ref,
) async {
  final result = await ref.read(homeRepositoryProvider).getMostDiscounted();
  return result.fold((failure) => throw failure, (products) => products);
});

final brandProductsProvider =
    FutureProvider.family<List<ProductSummary>, String>((ref, brand) async {
      final result = await ref
          .read(homeRepositoryProvider)
          .getProductsByBrand(brand);
      return result.fold((failure) => throw failure, (products) => products);
    });
