import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/search/controller/search_controller.dart';
import 'package:frontend/features/search/models/search_filters.dart';

class AllFiltersPage extends ConsumerWidget {
  final VoidCallback onOpenBrands;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenGenders;
  final VoidCallback onOpenStores;
  final VoidCallback onOpenPrice;

  const AllFiltersPage({
    super.key,
    required this.onOpenBrands,
    required this.onOpenCategories,
    required this.onOpenGenders,
    required this.onOpenStores,
    required this.onOpenPrice,
  });

  Widget _buildFilterRow({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      onPressed: onTap,
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.horizontalSpacing(context),
          vertical: Constants.height(context) * 0.02,
        ),
        decoration: BoxDecoration(
          color: Palette.backgroundColor,
          // No bottom border or full border? The screenshot has no line separators
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: TextSizes.medium(context),
                fontWeight: FontWeight.normal,
                color: Palette.blackColor,
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Palette.blackColor,
              size: Constants.iconSize(context) * 0.8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    double height = Constants.height(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Constants.horizontalSpacing(context),
      ).copyWith(top: height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: TextSizes.medium(context),
              fontWeight: FontWeight.normal,
              color: Palette.blackColor,
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  int _countActiveFilters(SearchFilters filters) {
    int count =
        filters.brands.length +
        filters.categories.length +
        filters.genders.length +
        filters.sources.length;

    if (filters.minPrice != null || filters.maxPrice != null) count++;
    if (filters.onlyDiscounted) count++;

    return count;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    double width = Constants.width(context);

    final filters = ref.watch(searchFiltersProvider);
    final filterCount = _countActiveFilters(filters);

    return CupertinoPageScaffold(
      backgroundColor: Palette.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
                vertical: height * 0.02,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Palette.borderColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Constants.iconSize(context),
                  ), // Placeholder for balance
                  Text(
                    "Filters",
                    style: TextStyle(
                      fontSize: TextSizes.medium(context),
                      fontWeight: FontWeight.bold,
                      color: Palette.blackColor,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.clear,
                      size: Constants.iconSize(context),
                      color: Palette.blackColor,
                    ),
                  ),
                ],
              ),
            ),

            // Body: scrollable filter list
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: height * 0.01),
                children: [
                  _buildFilterRow(
                    context: context,
                    label: "Brands",
                    onTap: onOpenBrands,
                  ),
                  _buildFilterRow(
                    context: context,
                    label: "Categories",
                    onTap: onOpenCategories,
                  ),
                  _buildFilterRow(
                    context: context,
                    label: "Genders",
                    onTap: onOpenGenders,
                  ),
                  _buildFilterRow(
                    context: context,
                    label: "Stores",
                    onTap: onOpenStores,
                  ),
                  _buildFilterRow(
                    context: context,
                    label: "Price",
                    onTap: onOpenPrice,
                  ),

                  // Slight spacing to separate from toggles
                  _buildToggleRow(
                    context: context,
                    label: "Sale",
                    value: filters.onlyDiscounted,
                    onChanged: (val) {
                      ref
                          .read(searchFiltersProvider.notifier)
                          .update((s) => s.copyWith(onlyDiscounted: val));
                      ref.read(searchResultsProvider.notifier).search();
                    },
                  ),
                ],
              ),
            ),

            // Bottom Sticky Bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
                vertical: height * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // Clear all filters
                        ref.read(searchFiltersProvider.notifier).state =
                            const SearchFilters();
                        ref.read(searchResultsProvider.notifier).search();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.backgroundColor,
                          border: Border.all(
                            color: filterCount > 0
                                ? Palette.blackColor
                                : Palette.borderColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            Constants.borderRadius(context),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: height * 0.015),
                        child: Text(
                          "Clear All",
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: filterCount > 0
                                ? Palette.blackColor
                                : Palette.mediumGreyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.blackColor,
                          border: Border.all(color: Palette.blackColor),
                          borderRadius: BorderRadius.circular(
                            Constants.borderRadius(context),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: height * 0.015),
                        child: Text(
                          filterCount > 0
                              ? "Apply filters ($filterCount)"
                              : "Apply filters",
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
