enum SearchSortOption { newest, priceLowToHigh, priceHighToLow }

class SearchFilters {
  final List<String> brands;
  final List<String> categories;
  final List<String> genders;
  final List<String> sources;
  final double? minPrice;
  final double? maxPrice;
  final bool onlyDiscounted;
  final SearchSortOption sortOption;

  const SearchFilters({
    this.brands = const [],
    this.categories = const [],
    this.genders = const [],
    this.sources = const [],
    this.minPrice,
    this.maxPrice,
    this.onlyDiscounted = false,
    this.sortOption = SearchSortOption.newest,
  });

  SearchFilters copyWith({
    List<String>? brands,
    List<String>? categories,
    List<String>? genders,
    List<String>? sources,
    double? minPrice,
    double? maxPrice,
    bool? onlyDiscounted,
    SearchSortOption? sortOption,
  }) {
    return SearchFilters(
      brands: brands ?? this.brands,
      categories: categories ?? this.categories,
      genders: genders ?? this.genders,
      sources: sources ?? this.sources,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyDiscounted: onlyDiscounted ?? this.onlyDiscounted,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  SearchFilters copyWithPrice({
    double? minPrice,
    double? maxPrice,
    bool clearPrice = false,
  }) {
    return SearchFilters(
      brands: brands,
      categories: categories,
      genders: genders,
      sources: sources,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      onlyDiscounted: onlyDiscounted,
      sortOption: sortOption,
    );
  }

  bool get hasAnyFilterActive =>
      brands.isNotEmpty ||
      categories.isNotEmpty ||
      genders.isNotEmpty ||
      sources.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      onlyDiscounted;
}
