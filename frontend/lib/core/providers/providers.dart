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

  static const _recentSearchesKey = 'recent_searches';

  List<String> getRecentSearches() {
    return sharedPreferences.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> addRecentSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query); // Remove if exists to put it at the beginning
    searches.insert(0, query);
    // Keep max 10
    if (searches.length > 10) {
      searches.removeLast();
    }
    await sharedPreferences.setStringList(_recentSearchesKey, searches);
  }

  Future<void> removeRecentSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query);
    await sharedPreferences.setStringList(_recentSearchesKey, searches);
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
