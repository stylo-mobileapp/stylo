import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final sharedPreferencesProvider = Provider(
  (ref) => SharedPreferencesController(),
);

class SharedPreferencesController {
  late SharedPreferences sharedPreferences;

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }
}

final fetchAllBrandsProvider = FutureProvider<List<String>>((ref) async {
  final response = await ref
      .read(supabaseClientProvider)
      .from("mv_brands")
      .select("name")
      .order("product_count", ascending: false);

  return (response as List).map((row) => row['name'] as String).toList();
});
