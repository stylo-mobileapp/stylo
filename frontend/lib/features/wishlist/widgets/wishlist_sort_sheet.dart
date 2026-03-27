import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/wishlist/controller/wishlist_controller.dart';

void showWishlistSortSheet(BuildContext context) {
  double height = Constants.height(context);
  double width = Constants.width(context);

  showCupertinoModalPopup(
    context: context,
    builder: (context) {
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
              Consumer(
                builder: (context, ref, _) {
                  final currentSort = ref.watch(wishlistSortProvider);
                  return Column(
                    children: WishlistSortOption.values.map((option) {
                      String title;
                      switch (option) {
                        case WishlistSortOption.lastSaved:
                          title = "Last Saved";
                          break;
                        case WishlistSortOption.priceHighToLow:
                          title = "Price - High to Low";
                          break;
                        case WishlistSortOption.priceLowToHigh:
                          title = "Price - Low to High";
                          break;
                      }
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref.read(wishlistSortProvider.notifier).state =
                              option;
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
                                currentSort == option
                                    ? CupertinoIcons.circle_fill
                                    : CupertinoIcons.circle,
                                size: Constants.iconSize(context),
                              ),
                              SizedBox(width: width * 0.025),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: TextSizes.medium(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
