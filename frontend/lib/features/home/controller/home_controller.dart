import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/home/repository/home_repository.dart';
import 'package:frontend/models/home_section.dart';

final homeControllerProvider =
    StateNotifierProvider<HomeController, AsyncValue<List<HomeSection>>>(
      (ref) => HomeController(ref.read(homeRepositoryProvider), ref),
    );

class HomeController extends StateNotifier<AsyncValue<List<HomeSection>>> {
  final HomeRepository homeRepository;
  final Ref ref;

  HomeController(this.homeRepository, this.ref)
    : super(const AsyncValue.loading());

  Future<void> loadHomeSections() async {
    state = const AsyncValue.loading();

    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      final sections = <HomeSection>[];

      // CALL CONSOLIDATED RPC
      final homeContentResult = await homeRepository.getHomeContent(userId);

      final Map<String, dynamic> data = homeContentResult.fold(
        (failure) => throw Exception(failure.message),
        (data) => data,
      );

      final List<String> userBrandNames = List<String>.from(
        data['user_brands'] ?? [],
      );
      final List<String> topBrandNames = List<String>.from(
        data['top_brands'] ?? [],
      );

      // Add 'recently viewed' section configuration
      sections.add(
        const HomeSection(
          title: 'Curated Just for You',
          subtitle: 'Inspired by your recent browsing',
          type: HomeSectionType.recentlyViewed,
        ),
      );

      final allBrandEntries = <({String brand, String title, String subtitle})>[
        ...userBrandNames.asMap().entries.map(
          (e) => (
            brand: e.value,
            title: e.key == 0 ? 'Just In: ${e.value}' : e.value,
            subtitle: e.key == 0 ? "See what's new from your top brand" : '',
          ),
        ),
        ...topBrandNames.asMap().entries.map(
          (e) => (
            brand: e.value,
            title: e.key == 0 ? 'Top Styles: ${e.value}' : e.value,
            subtitle: e.key == 0 ? 'Popular picks from the collection' : '',
          ),
        ),
      ];

      for (final entry in allBrandEntries) {
        sections.add(
          HomeSection(
            title: entry.title,
            subtitle: entry.subtitle,
            type: HomeSectionType.brand,
            brandQuery: entry.brand,
          ),
        );
      }

      // Add discounted section configuration
      sections.add(
        const HomeSection(
          title: "Don't Miss These Deals",
          subtitle: 'Explore our best active promotions',
          type: HomeSectionType.discounted,
        ),
      );

      state = AsyncValue.data(sections);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
