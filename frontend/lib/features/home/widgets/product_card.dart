import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/product/pages/product_page.dart';
import 'package:frontend/features/wishlist/controller/wishlist_controller.dart';
import 'package:frontend/models/product_summary.dart';
import 'package:overlay_support/overlay_support.dart';

class ProductCard extends ConsumerWidget {
  final ProductSummary product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    double spacing = Constants.horizontalSpacing(context);

    final wishlistState = ref.watch(wishlistControllerProvider);
    final isInWishlist =
        wishlistState.value?.any((p) => p.id == product.id) ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ProductPage(productId: product.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: (width - 3 * spacing) / 2,
            height: (width - 3 * spacing) / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Constants.borderRadius(context),
              ),
            ),
            foregroundDecoration: BoxDecoration(
              border: Border.all(color: Palette.borderColor),
              borderRadius: BorderRadius.circular(
                Constants.borderRadius(context),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              errorWidget: (context, url, error) => SizedBox(),
              placeholder: (context, url) => SizedBox(),
            ),
          ),
          SizedBox(height: height * 0.01),
          Row(
            children: [
              if (product.discountPercentage > 0) ...[
                Text(
                  '${product.originalPrice} €',
                  style: TextStyle(
                    fontSize: TextSizes.small(context),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: width * 0.01),
                Text(
                  '${product.price} €',
                  style: TextStyle(
                    fontSize: TextSizes.small(context),
                    fontWeight: FontWeight.bold,
                    color: Palette.redColor,
                  ),
                ),
              ] else
                Text(
                  '${product.price} €',
                  style: TextStyle(
                    fontSize: TextSizes.small(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () {
                  if (isInWishlist) {
                    ref
                        .read(wishlistControllerProvider.notifier)
                        .removeProduct(product.id);
                    showWishlistSnackbar(context, false);
                  } else {
                    ref
                        .read(wishlistControllerProvider.notifier)
                        .addProduct(product);
                    showWishlistSnackbar(context, true);
                  }
                },
                child: Icon(
                  isInWishlist
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: isInWishlist ? Palette.redColor : Palette.blackColor,
                  size: Constants.iconSize(context),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.005),
          Text(
            product.brand,
            style: TextStyle(fontSize: TextSizes.small(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: height * 0.005),
          Text(
            product.title,
            style: TextStyle(
              fontSize: TextSizes.small(context),
              color: Palette.mediumGreyColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

void showWishlistSnackbar(BuildContext context, bool added) {
  showOverlayNotification(
    (context) {
      double height = Constants.height(context);
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom:
                  Constants.horizontalSpacing(context) +
                  height * 0.025 +
                  MediaQuery.of(context).padding.bottom,
              left: Constants.horizontalSpacing(context),
              right: Constants.horizontalSpacing(context),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalSpacing(context),
                  vertical: height * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Palette.blackColor,
                  borderRadius: BorderRadius.circular(
                    Constants.borderRadius(context),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      added
                          ? "Item added to Wishlist"
                          : "Item removed from Wishlist",
                      style: TextStyle(
                        color: Palette.whiteColor,
                        fontSize: TextSizes.medium(context),
                      ),
                    ),
                    Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () {
                        OverlaySupportEntry.of(context)?.dismiss();
                      },
                      child: Icon(
                        CupertinoIcons.clear,
                        color: Palette.whiteColor,
                        size: Constants.iconSize(context) * 0.75,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    duration: const Duration(seconds: 3),
    position: NotificationPosition.bottom,
  );
}
