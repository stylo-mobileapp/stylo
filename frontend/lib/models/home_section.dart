enum HomeSectionType { recentlyViewed, discounted, brand }

class HomeSection {
  final String title;
  final String subtitle;
  final HomeSectionType type;
  final String? brandQuery;

  const HomeSection({
    required this.title,
    required this.subtitle,
    required this.type,
    this.brandQuery,
  });
}
