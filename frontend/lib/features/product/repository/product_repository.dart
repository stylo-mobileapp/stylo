import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/failure/failure.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/product_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productRepositoryProvider = Provider(
  (ref) => ProductRepository(ref.read(supabaseClientProvider)),
);

class ProductRepository {
  final SupabaseClient supabaseClient;
  ProductRepository(this.supabaseClient);

  Future<Either<Failure, Product>> getProductById(String productId) async {
    try {
      final response = await supabaseClient
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      return right(Product.fromJson(response));
    } catch (e) {
      return left(Failure("Couldn't load product details."));
    }
  }

  Future<void> trackViewedProduct(String userId, String productId) async {
    try {
      await supabaseClient.from('viewed_products').upsert({
        'user_id': userId,
        'product_id': productId,
      }, onConflict: 'user_id, product_id');
    } catch (_) {
      // Silently fail – tracking should not block the user experience
    }
  }

  Future<Either<Failure, List<ProductSummary>>> getRelatedProducts({
    required String brand,
    required String category,
    required String gender,
    required String excludeProductId,
    int limit = 20,
  }) async {
    try {
      final response = await supabaseClient
          .from('products')
          .select(ProductSummary.selectColumns)
          .eq('brand', brand)
          .eq('category', category)
          .eq('gender', gender)
          .neq('id', excludeProductId)
          .order('created_at', ascending: false)
          .limit(limit);

      final products = (response as List)
          .map((row) => ProductSummary.fromJson(row as Map<String, dynamic>))
          .toList();

      return right(products);
    } catch (e) {
      return left(Failure("Couldn't load related products."));
    }
  }
}
