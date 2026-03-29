import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/wishlist/controller/wishlist_controller.dart';
import 'package:frontend/features/home/widgets/product_card.dart';
import 'package:frontend/features/wishlist/widgets/wishlist_sort_sheet.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    final wishlistState = ref.watch(sortedWishlistProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.bell,
                          size: Constants.iconSize(context),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Wishlist",
                        style: TextStyle(
                          fontSize: TextSizes.medium(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.person,
                          size: Constants.iconSize(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: wishlistState.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.horizontalSpacing(context),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.heart_fill,
                            size: Constants.iconSize(context) * 2,
                          ),
                          SizedBox(height: height * 0.02),
                          Text(
                            "Save products you love by tapping the heart icon",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: TextSizes.large(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Text(
                            "Save and track items",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: TextSizes.medium(context),
                              color: Palette.mediumGreyColor,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            "Personalised recommendations",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: TextSizes.medium(context),
                              color: Palette.mediumGreyColor,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            "Save and back in stock alerts",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: TextSizes.medium(context),
                              color: Palette.mediumGreyColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: () async {
                          await ref
                              .read(wishlistControllerProvider.notifier)
                              .loadWishlist();
                        },
                        builder:
                            (
                              context,
                              refreshState,
                              pulledExtent,
                              refreshTriggerPullDistance,
                              refreshIndicatorExtent,
                            ) {
                              final double percentage =
                                  (pulledExtent / refreshIndicatorExtent).clamp(
                                    0.0,
                                    1.0,
                                  );

                              return Transform.scale(
                                scale: refreshState == RefreshIndicatorMode.drag
                                    ? Curves.easeOut.transform(percentage)
                                    : 1.0,
                                child: Opacity(
                                  opacity:
                                      refreshState == RefreshIndicatorMode.drag
                                      ? percentage
                                      : 1.0,
                                  child: const Loading(),
                                ),
                              );
                            },
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.horizontalSpacing(context),
                            vertical: Constants.horizontalSpacing(context) / 2,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: height * 0.01),
                            child: Row(
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  onPressed: () =>
                                      showWishlistSortSheet(context),
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
                                        size:
                                            Constants.iconSize(context) * 0.75,
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "${products.length} ",
                                  style: TextStyle(
                                    fontSize: TextSizes.small(context),
                                  ),
                                ),
                                Text(
                                  products.length == 1 ? "result" : "results",
                                  style: TextStyle(
                                    fontSize: TextSizes.small(context),
                                    color: Palette.mediumGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                                bottom: index < (products.length / 2).ceil() - 1
                                    ? Constants.horizontalSpacing(context) * 1.5
                                    : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ProductCard(product: products[i]),
                                  ),
                                  SizedBox(
                                    width: Constants.horizontalSpacing(context),
                                  ),
                                  if (i + 1 < products.length)
                                    Expanded(
                                      child: ProductCard(
                                        product: products[i + 1],
                                      ),
                                    )
                                  else
                                    Expanded(child: const SizedBox()),
                                ],
                              ),
                            );
                          }, childCount: (products.length / 2).ceil()),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Loading(),
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
                          "Couldn't load your wishlist.\nPlease try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.mediumGreyColor,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => ref
                              .read(wishlistControllerProvider.notifier)
                              .loadWishlist(),
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
