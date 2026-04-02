import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/home/widgets/product_card.dart'
    show showWishlistSnackbar;
import 'package:frontend/features/wishlist/controller/wishlist_controller.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/product_summary.dart';

class ProductInfoSection extends ConsumerWidget {
  final Product product;
  final VoidCallback onSeeMoreLikeThis;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.onSeeMoreLikeThis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);

    final wishlistState = ref.watch(wishlistControllerProvider);
    final isInWishlist =
        wishlistState.value?.any((p) => p.id == product.id) ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height * 0.02),

        // "See more like this" button
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: onSeeMoreLikeThis,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: height * 0.015),
            decoration: BoxDecoration(
              border: Border.all(color: Palette.blackColor),
              borderRadius: BorderRadius.circular(
                Constants.borderRadius(context),
              ),
            ),
            child: Center(
              child: Text(
                'See more like this',
                style: TextStyle(
                  color: Palette.blackColor,
                  fontSize: TextSizes.medium(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: height * 0.02),

        // Brand + title + wishlist
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: TextSizes.extraLarge(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: TextSizes.medium(context),
                      color: Palette.mediumGreyColor,
                    ),
                  ),
                ],
              ),
            ),
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
                      .addProduct(
                        ProductSummary(
                          id: product.id,
                          imageUrl: product.imageUrl,
                          brand: product.brand,
                          title: product.title,
                          originalPrice: product.originalPrice,
                          price: product.price,
                          discountPercentage: product.discountPercentage,
                        ),
                      );
                  showWishlistSnackbar(context, true);
                }
              },
              child: Icon(
                isInWishlist ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: isInWishlist ? Palette.redColor : Palette.blackColor,
                size: Constants.iconSize(context) * 1.25,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
