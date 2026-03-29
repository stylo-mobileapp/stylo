import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/home/widgets/product_card.dart';
import 'package:frontend/features/search/controller/search_controller.dart';
import 'package:frontend/features/search/widgets/brands_filter_sheet.dart';
import 'package:frontend/features/search/widgets/all_filters_page.dart';
import 'package:frontend/features/search/widgets/filter_bottom_sheets.dart';
import 'package:frontend/features/search/widgets/search_sort_sheet.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key});

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late TextEditingController _textController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchResultsProvider.notifier).search();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchResultsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    ref.read(searchQueryProvider.notifier).state = query.trim();
    ref.read(recentSearchesProvider.notifier).add(query.trim());
    ref.read(searchResultsProvider.notifier).search();
  }

  // --- Filter Helpers ---

  void _openBrandsFilter() async {
    try {
      final options = await ref.read(filterBrandsProvider.future);
      if (!mounted) return;
      showBrandsFilterSheet(
        context: context,
        allOptions: options,
        initiallySelected: ref.read(searchFiltersProvider).brands,
        onApply: (selected) {
          ref
              .read(searchFiltersProvider.notifier)
              .update((s) => s.copyWith(brands: selected));
          ref.read(searchResultsProvider.notifier).search();
        },
      );
    } catch (e) {
      debugPrint("Could not load brands");
    }
  }

  void _openCategoriesFilter() async {
    try {
      final options = await ref.read(filterCategoriesProvider.future);
      if (!mounted) return;
      showMultiSelectFilterSheet(
        context: context,
        title: 'CATEGORY',
        allOptions: options,
        initiallySelected: ref.read(searchFiltersProvider).categories,
        onApply: (selected) {
          ref
              .read(searchFiltersProvider.notifier)
              .update((s) => s.copyWith(categories: selected));
          ref.read(searchResultsProvider.notifier).search();
        },
      );
    } catch (e) {
      debugPrint("Could not load categories");
    }
  }

  void _openGendersFilter() async {
    try {
      final options = await ref.read(filterGendersProvider.future);
      if (!mounted) return;
      showMultiSelectFilterSheet(
        context: context,
        title: 'GENDER',
        allOptions: options,
        initiallySelected: ref.read(searchFiltersProvider).genders,
        onApply: (selected) {
          ref
              .read(searchFiltersProvider.notifier)
              .update((s) => s.copyWith(genders: selected));
          ref.read(searchResultsProvider.notifier).search();
        },
      );
    } catch (e) {
      debugPrint("Could not load genders");
    }
  }

  void _openSourcesFilter() async {
    try {
      final options = await ref.read(filterSourcesProvider.future);
      if (!mounted) return;
      showMultiSelectFilterSheet(
        context: context,
        title: 'STORE',
        allOptions: options,
        initiallySelected: ref.read(searchFiltersProvider).sources,
        onApply: (selected) {
          ref
              .read(searchFiltersProvider.notifier)
              .update((s) => s.copyWith(sources: selected));
          ref.read(searchResultsProvider.notifier).search();
        },
      );
    } catch (e) {
      debugPrint("Could not load sources");
    }
  }

  void _openPriceFilter() {
    final filters = ref.read(searchFiltersProvider);
    showPriceFilterSheet(
      context: context,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      onApply: (minP, maxP) {
        if (minP == null && maxP == null) {
          ref
              .read(searchFiltersProvider.notifier)
              .update((s) => s.copyWithPrice(clearPrice: true));
        } else {
          ref
              .read(searchFiltersProvider.notifier)
              .update((s) => s.copyWithPrice(minPrice: minP, maxPrice: maxP));
        }
        ref.read(searchResultsProvider.notifier).search();
      },
    );
  }

  void _openAllFilters() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => AllFiltersPage(
          onOpenBrands: _openBrandsFilter,
          onOpenCategories: _openCategoriesFilter,
          onOpenGenders: _openGendersFilter,
          onOpenStores: _openSourcesFilter,
          onOpenPrice: _openPriceFilter,
        ),
      ),
    );
  }

  void _toggleDiscountFilter() {
    ref
        .read(searchFiltersProvider.notifier)
        .update((s) => s.copyWith(onlyDiscounted: !s.onlyDiscounted));
    ref.read(searchResultsProvider.notifier).search();
  }

  // --- UNIFIED FILTER CHIP ---
  Widget _buildUnifiedFilterChip({
    String? label,
    IconData? icon,
    required bool isActive,
    required VoidCallback onTap,
    bool hasArrow = false,
    bool isCircle = false,
    bool isText = false,
  }) {
    double width = Constants.width(context);
    double textSize = TextSizes.small(context); // Resizable based on TextSizes

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: isText
          ? Text(
              label!,
              style: TextStyle(
                color: isActive ? Palette.goldColor : Palette.blackColor,
                fontSize: textSize,
                decoration: TextDecoration.underline,
              ),
            )
          : Container(
              margin: EdgeInsets.only(right: width * 0.025),
              padding: EdgeInsets.symmetric(
                horizontal: isCircle ? width * 0.02 : width * 0.035,
                vertical: width * 0.02,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isActive ? Palette.goldColor : Palette.blackColor,
                ),
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircle
                    ? null
                    : BorderRadius.circular(
                        Constants.borderRadius(context) * 2,
                      ), // Pill shape for all
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: textSize * 1.3, // Icon scaled by TextSizes
                      color: isActive ? Palette.goldColor : Palette.blackColor,
                    ),
                    if (label != null) SizedBox(width: width * 0.015),
                  ],
                  if (label != null)
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive
                            ? Palette.goldColor
                            : Palette.blackColor,
                        fontSize: textSize,
                      ),
                    ),
                  if (hasArrow) ...[
                    SizedBox(width: width * 0.015),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: textSize, // Arrow scaled by TextSizes
                      color: isActive ? Palette.goldColor : Palette.blackColor,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = Constants.width(context);
    double height = Constants.height(context);
    final filtersInfo = ref.watch(searchFiltersProvider);
    final resultsState = ref.watch(searchResultsProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.arrow_left,
                      size: Constants.iconSize(context),
                    ),
                  ),
                  SizedBox(width: width * 0.025),
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: _textController,
                      onSubmitted: _onSearch,
                      placeholder: "What are you searching for?",
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.01),
            // Filter Chips container
            SizedBox(
              height:
                  TextSizes.small(context) * 3 +
                  width * 0.02, // Adapted height for text scaling
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalSpacing(context),
                  vertical: 4,
                ),
                children: [
                  _buildUnifiedFilterChip(
                    icon: CupertinoIcons.slider_horizontal_3,
                    isActive: filtersInfo.hasAnyFilterActive,
                    onTap: _openAllFilters,
                    isCircle: true,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'Sale',
                    isActive: filtersInfo.onlyDiscounted,
                    onTap: _toggleDiscountFilter,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'Brands',
                    isActive: filtersInfo.brands.isNotEmpty,
                    onTap: _openBrandsFilter,
                    hasArrow: true,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'Category',
                    isActive: filtersInfo.categories.isNotEmpty,
                    onTap: _openCategoriesFilter,
                    hasArrow: true,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'Gender',
                    isActive: filtersInfo.genders.isNotEmpty,
                    onTap: _openGendersFilter,
                    hasArrow: true,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'Store',
                    isActive: filtersInfo.sources.isNotEmpty,
                    onTap: _openSourcesFilter,
                    hasArrow: true,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'Price',
                    isActive:
                        filtersInfo.minPrice != null ||
                        filtersInfo.maxPrice != null,
                    onTap: _openPriceFilter,
                    hasArrow: true,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'All filters',
                    isActive: false,
                    onTap: _openAllFilters,
                    isText: true,
                  ),
                ],
              ),
            ),
            // Results area
            Expanded(
              child: resultsState.products.when(
                data: (products) {
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.horizontalSpacing(context),
                          ).copyWith(top: height * 0.01),
                          child: Row(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                onPressed: () => showSearchSortSheet(context),
                                child: Row(
                                  children: [
                                    Text(
                                      "Sort by",
                                      style: TextStyle(
                                        fontSize: TextSizes.small(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.01),
                                    Icon(
                                      CupertinoIcons.chevron_down,
                                      size: Constants.iconSize(context) * 0.75,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${products.length}+ ",
                                style: TextStyle(
                                  fontSize: TextSizes.small(context),
                                ),
                              ),
                              Text(
                                "results",
                                style: TextStyle(
                                  fontSize: TextSizes.small(context),
                                  color: Palette.mediumGreyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (products.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: height * 0.02),
                            child: Center(
                              child: Text(
                                "No products found for \"${_textController.text}\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: TextSizes.medium(context),
                                  color: Palette.mediumGreyColor,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.horizontalSpacing(context),
                            vertical: Constants.horizontalSpacing(context),
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              int i = index * 2;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index < (products.length / 2).ceil() - 1
                                      ? Constants.horizontalSpacing(context) *
                                            1.5
                                      : 0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ProductCard(product: products[i]),
                                    ),
                                    SizedBox(
                                      width: Constants.horizontalSpacing(
                                        context,
                                      ),
                                    ),
                                    if (i + 1 < products.length)
                                      Expanded(
                                        child: ProductCard(
                                          product: products[i + 1],
                                        ),
                                      )
                                    else
                                      const Expanded(child: SizedBox()),
                                  ],
                                ),
                              );
                            }, childCount: (products.length / 2).ceil()),
                          ),
                        ),
                      if (resultsState.isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.02,
                            ),
                            child: const Loading(),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Loading(),
                error: (error, stack) => SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constants.horizontalSpacing(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Couldn't load search results.\nPlease try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.mediumGreyColor,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              ref.read(searchResultsProvider.notifier).search(),
                          child: Text(
                            "Try again",
                            style: TextStyle(
                              fontSize: TextSizes.medium(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
