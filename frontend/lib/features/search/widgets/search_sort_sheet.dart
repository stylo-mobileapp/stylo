import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/search/controller/search_controller.dart';
import 'package:frontend/features/search/models/search_filters.dart';

void showSearchSortSheet(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => const SearchSortSheet(),
  );
}

class SearchSortSheet extends ConsumerWidget {
  const SearchSortSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    final filters = ref.watch(searchFiltersProvider);

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
                    child: Icon(null, size: Constants.iconSize(context)),
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
                String title;
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
                    ref.read(searchFiltersProvider.notifier).update((state) {
                      return state.copyWith(sortOption: option);
                    });
                    ref.read(searchResultsProvider.notifier).search();
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
                        ),
                        SizedBox(width: width * 0.025),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: CupertinoColors.label,
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
  }
}
