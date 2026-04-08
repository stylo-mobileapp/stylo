import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/home/widgets/product_card.dart';
import 'package:frontend/features/product/controller/brand_products_controller.dart';
import 'package:frontend/features/search/controller/search_controller.dart';
import 'package:frontend/features/search/widgets/all_filters_page.dart';
import 'package:frontend/features/search/widgets/filter_bottom_sheets.dart';
import 'package:frontend/features/search/models/search_filters.dart';

class BrandProductsPage extends ConsumerStatefulWidget {
  final String brand;

  const BrandProductsPage({super.key, required this.brand});

  @override
  ConsumerState<BrandProductsPage> createState() => _BrandProductsPageState();
}

class _BrandProductsPageState extends ConsumerState<BrandProductsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(brandProductsResultsProvider(widget.brand).notifier).fetch();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(brandProductsResultsProvider(widget.brand).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Filter Helpers ---

  void _openCategoriesFilter() async {
    try {
      final options = await ref.read(filterCategoriesProvider.future);
      if (!mounted) return;
      showMultiSelectFilterSheet(
        context: context,
        title: 'CATEGORY',
        allOptions: options,
        initiallySelected: ref
            .read(brandProductsFiltersProvider(widget.brand))
            .categories,
        onApply: (selected) {
          ref
              .read(brandProductsFiltersProvider(widget.brand).notifier)
              .update((s) => s.copyWith(categories: selected));
          ref.read(brandProductsResultsProvider(widget.brand).notifier).fetch();
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
        initiallySelected: ref
            .read(brandProductsFiltersProvider(widget.brand))
            .genders,
        onApply: (selected) {
          ref
              .read(brandProductsFiltersProvider(widget.brand).notifier)
              .update((s) => s.copyWith(genders: selected));
          ref.read(brandProductsResultsProvider(widget.brand).notifier).fetch();
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
        initiallySelected: ref
            .read(brandProductsFiltersProvider(widget.brand))
            .sources,
        onApply: (selected) {
          ref
              .read(brandProductsFiltersProvider(widget.brand).notifier)
              .update((s) => s.copyWith(sources: selected));
          ref.read(brandProductsResultsProvider(widget.brand).notifier).fetch();
        },
      );
    } catch (e) {
      debugPrint("Could not load sources");
    }
  }

  void _openPriceFilter() {
    final filters = ref.read(brandProductsFiltersProvider(widget.brand));
    showPriceFilterSheet(
      context: context,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      onApply: (minP, maxP) {
        if (minP == null && maxP == null) {
          ref
              .read(brandProductsFiltersProvider(widget.brand).notifier)
              .update((s) => s.copyWithPrice(clearPrice: true));
        } else {
          ref
              .read(brandProductsFiltersProvider(widget.brand).notifier)
              .update((s) => s.copyWithPrice(minPrice: minP, maxPrice: maxP));
        }
        ref.read(brandProductsResultsProvider(widget.brand).notifier).fetch();
      },
    );
  }

  void _openAllFilters() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (_) => _BrandAllFiltersPageWrapper(
          brand: widget.brand,
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
        .read(brandProductsFiltersProvider(widget.brand).notifier)
        .update((s) => s.copyWith(onlyDiscounted: !s.onlyDiscounted));
    ref.read(brandProductsResultsProvider(widget.brand).notifier).fetch();
  }

  void _showSortSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            double height = Constants.height(context);
            double width = Constants.width(context);
            final filters = ref.watch(
              brandProductsFiltersProvider(widget.brand),
            );

            return Container(
              decoration: BoxDecoration(
                color: Palette.backgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Constants.borderRadius(context) * 2),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: height * 0.01),
                      width: width * 0.1,
                      height: height * 0.005,
                      decoration: BoxDecoration(
                        color: Palette.borderColor,
                        borderRadius: BorderRadius.circular(
                          Constants.borderRadius(context),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.horizontalSpacing(context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                            child: Icon(
                              null,
                              size: Constants.iconSize(context),
                            ),
                          ),
                          Text(
                            "SORT BY",
                            style: TextStyle(
                              fontSize: TextSizes.medium(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            child: Icon(
                              CupertinoIcons.clear,
                              size: Constants.iconSize(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: SearchSortOption.values.map((option) {
                        String title = "";
                        switch (option) {
                          case SearchSortOption.newest:
                            title = "Newest";
                            break;
                          case SearchSortOption.priceHighToLow:
                            title = "Price - High to Low";
                            break;
                          case SearchSortOption.priceLowToHigh:
                            title = "Price - Low to High";
                            break;
                        }

                        bool isSelected = option == filters.sortOption;

                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ref
                                .read(
                                  brandProductsFiltersProvider(
                                    widget.brand,
                                  ).notifier,
                                )
                                .update(
                                  (state) => state.copyWith(sortOption: option),
                                );
                            ref
                                .read(
                                  brandProductsResultsProvider(
                                    widget.brand,
                                  ).notifier,
                                )
                                .fetch();
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Constants.horizontalSpacing(context),
                              vertical: height * 0.015,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? CupertinoIcons.circle_fill
                                      : CupertinoIcons.circle,
                                  size: Constants.iconSize(context),
                                  color: Palette.blackColor,
                                ),
                                SizedBox(width: width * 0.025),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: TextSizes.medium(context),
                                    color: Palette.blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    double textSize = TextSizes.small(context);

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
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: textSize * 1.3,
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
                      size: textSize,
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
    final filtersInfo = ref.watch(brandProductsFiltersProvider(widget.brand));
    final resultsState = ref.watch(brandProductsResultsProvider(widget.brand));

    // Calculate if any filter (except the locked brand) is active
    final hasActiveUserFilters =
        filtersInfo.onlyDiscounted ||
        filtersInfo.categories.isNotEmpty ||
        filtersInfo.genders.isNotEmpty ||
        filtersInfo.sources.isNotEmpty ||
        filtersInfo.minPrice != null ||
        filtersInfo.maxPrice != null;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ).copyWith(bottom: height * 0.01),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.arrow_left,
                      size: Constants.iconSize(context),
                      color: Palette.blackColor,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.brand,
                        style: TextStyle(
                          fontSize: TextSizes.medium(context),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () {},
                    child: Icon(null, size: Constants.iconSize(context)),
                  ),
                ],
              ),
            ),
            // Filter Chips container
            SizedBox(
              height: TextSizes.small(context) * 3 + width * 0.02,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalSpacing(context),
                  vertical: 4,
                ),
                children: [
                  _buildUnifiedFilterChip(
                    icon: CupertinoIcons.slider_horizontal_3,
                    isActive: hasActiveUserFilters,
                    onTap: _openAllFilters,
                    isCircle: true,
                  ),
                  _buildUnifiedFilterChip(
                    label: 'Sale',
                    isActive: filtersInfo.onlyDiscounted,
                    onTap: _toggleDiscountFilter,
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
                                onPressed: _showSortSheet,
                                child: Row(
                                  children: [
                                    Text(
                                      "Sort by",
                                      style: TextStyle(
                                        fontSize: TextSizes.small(context),
                                        fontWeight: FontWeight.bold,
                                        color: Palette.blackColor,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.01),
                                    Icon(
                                      CupertinoIcons.chevron_down,
                                      size: Constants.iconSize(context) * 0.75,
                                      color: Palette.blackColor,
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
                                "No products found for ${widget.brand}.",
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
                          "Couldn't load ${widget.brand} products.\nPlease try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.mediumGreyColor,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => ref
                              .read(
                                brandProductsResultsProvider(
                                  widget.brand,
                                ).notifier,
                              )
                              .fetch(),
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

class _BrandAllFiltersPageWrapper extends ConsumerWidget {
  final String brand;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenGenders;
  final VoidCallback onOpenStores;
  final VoidCallback onOpenPrice;

  const _BrandAllFiltersPageWrapper({
    required this.brand,
    required this.onOpenCategories,
    required this.onOpenGenders,
    required this.onOpenStores,
    required this.onOpenPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(brandProductsFiltersProvider(brand));
    return AllFiltersPage(
      filters: filters,
      showBrands: false,
      onOpenBrands: () {},
      onOpenCategories: onOpenCategories,
      onOpenGenders: onOpenGenders,
      onOpenStores: onOpenStores,
      onOpenPrice: onOpenPrice,
      onSaleToggled: (val) {
        ref
            .read(brandProductsFiltersProvider(brand).notifier)
            .update((s) => s.copyWith(onlyDiscounted: val));
        ref.read(brandProductsResultsProvider(brand).notifier).fetch();
      },
      onClearAll: () {
        ref.read(brandProductsFiltersProvider(brand).notifier).state =
            SearchFilters(brands: [brand]);
        ref.read(brandProductsResultsProvider(brand).notifier).fetch();
      },
    );
  }
}
