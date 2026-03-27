import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/failure/failure.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/models/product_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final wishlistRepositoryProvider = Provider(
  (ref) => WishlistRepository(ref.read(supabaseClientProvider)),
);

class WishlistRepository {
  final SupabaseClient supabaseClient;
  WishlistRepository(this.supabaseClient);

  Future<Either<Failure, List<ProductSummary>>> getWishlistProducts(
    String userId,
  ) async {
    try {
      final response = await supabaseClient
          .from('wishlist')
          .select('product_id, products(${ProductSummary.selectColumns})')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final products = (response as List).map((row) {
        return ProductSummary.fromJson(row['products'] as Map<String, dynamic>);
      }).toList();

      return right(products);
    } catch (e) {
      return left(Failure("Couldn't load wishlist products."));
    }
  }

  Future<Either<Failure, void>> addProductToWishlist(
    String userId,
    String productId,
  ) async {
    try {
      await supabaseClient.from('wishlist').insert({
        'user_id': userId,
        'product_id': productId,
      });
      return right(null);
    } catch (e) {
      return left(Failure("Couldn't add product to wishlist."));
    }
  }

  Future<Either<Failure, void>> removeProductFromWishlist(
    String userId,
    String productId,
  ) async {
    try {
      await supabaseClient
          .from('wishlist')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
      return right(null);
    } catch (e) {
      return left(Failure("Couldn't remove product from wishlist."));
    }
  }
}
