import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/product/repository/product_repository.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/product_summary.dart';

final productProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  final repository = ref.read(productRepositoryProvider);

  final result = await repository.getProductById(productId);

  // Track viewed product in background
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId != null) {
    repository.trackViewedProduct(userId, productId);
  }

  return result.fold((failure) => throw failure, (product) => product);
});

final relatedProductsProvider =
    FutureProvider.family<List<ProductSummary>, Product>((ref, product) async {
      final repository = ref.read(productRepositoryProvider);

      final result = await repository.getRelatedProducts(
        brand: product.brand,
        category: product.category,
        gender: product.gender,
        excludeProductId: product.id,
      );

      return result.fold((failure) => [], (products) => products);
    });
