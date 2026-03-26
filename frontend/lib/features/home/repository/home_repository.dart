import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/failure/failure.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/models/product_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final homeRepositoryProvider = Provider(
  (ref) => HomeRepository(ref.read(supabaseClientProvider)),
);

class HomeRepository {
  final SupabaseClient supabaseClient;
  HomeRepository(this.supabaseClient);

  Future<Either<Failure, List<ProductSummary>>> getRecentlyViewed(
    String userId,
  ) async {
    try {
      final response = await supabaseClient
          .from('viewed_products')
          .select('product_id, products(${ProductSummary.selectColumns})')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(6);

      final products = (response as List).map((row) {
        return ProductSummary.fromJson(row['products'] as Map<String, dynamic>);
      }).toList();

      return right(products);
    } catch (e) {
      return left(Failure("Couldn't load recently viewed products."));
    }
  }

  Future<Either<Failure, List<ProductSummary>>> getProductsByBrand(
    String brand,
  ) async {
    try {
      final response = await supabaseClient
          .from('products')
          .select(ProductSummary.selectColumns)
          .eq('brand', brand)
          .order('created_at', ascending: false)
          .limit(6);

      final products = (response as List)
          .map((row) => ProductSummary.fromJson(row as Map<String, dynamic>))
          .toList();

      return right(products);
    } catch (e) {
      return left(Failure("Couldn't load products for $brand."));
    }
  }

  Future<Either<Failure, List<String>>> getTopBrands({int count = 3}) async {
    try {
      final response = await supabaseClient
          .from('mv_brands')
          .select('name')
          .order('product_count', ascending: false)
          .limit(count);

      final brands = (response as List)
          .map((row) => row['name'] as String)
          .toList();

      return right(brands);
    } catch (e) {
      return left(Failure("Couldn't load top brands."));
    }
  }

  Future<Either<Failure, List<String>>> getUserBrands(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select('brands')
          .eq('user_id', userId)
          .single();

      final brands = List<String>.from(response['brands'] as List);
      return right(brands);
    } catch (e) {
      return left(Failure("Couldn't load your brands."));
    }
  }

  Future<Either<Failure, List<ProductSummary>>> getMostDiscounted() async {
    try {
      final response = await supabaseClient
          .from('products')
          .select(ProductSummary.selectColumns)
          .order('discount_percentage', ascending: false)
          .limit(6);

      final products = (response as List)
          .map((row) => ProductSummary.fromJson(row as Map<String, dynamic>))
          .toList();

      return right(products);
    } catch (e) {
      return left(Failure("Couldn't load discounted products."));
    }
  }
}
