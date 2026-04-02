import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/models/product.dart';

class ProductPriceSection extends StatelessWidget {
  final Product product;
  final double displayPrice;
  final bool hasDiscount;
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;
  final VoidCallback onBuyNow;

  const ProductPriceSection({
    super.key,
    required this.product,
    required this.displayPrice,
    required this.hasDiscount,
    required this.selectedSize,
    required this.onSizeSelected,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    double width = Constants.width(context);
    double height = Constants.height(context);

    final displayCount = 4;
    final sizesToShow = product.availableSizes.take(displayCount).toList();
    final remaining = product.availableSizes.length - displayCount;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: height * 0.02,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.borderColor),
        borderRadius: BorderRadius.circular(Constants.borderRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasDiscount) ...[
                Text(
                  '${product.originalPrice} €',
                  style: TextStyle(
                    fontSize: TextSizes.large(context),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: width * 0.015),
              ],
              Text(
                '$displayPrice €',
                style: TextStyle(
                  fontSize: TextSizes.large(context),
                  fontWeight: FontWeight.bold,
                  color: hasDiscount ? Palette.redColor : Palette.blackColor,
                ),
              ),
              const Spacer(),
              if (hasDiscount)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.025,
                    vertical: width * 0.015,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Palette.goldColor),
                    borderRadius: BorderRadius.circular(
                      Constants.borderRadius(context),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: TextSizes.small(context),
                        color: Palette.goldColor,
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        '-${product.discountPercentage}%',
                        style: TextStyle(
                          fontSize: TextSizes.small(context),
                          color: Palette.goldColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: height * 0.005),

          // Source
          if (product.allSizes.isNotEmpty) ...[
            Text(
              'From ${product.source}',
              style: TextStyle(
                fontSize: TextSizes.medium(context),
                color: Palette.mediumGreyColor,
              ),
            ),
            SizedBox(height: height * 0.02),
            // Size chips
            Wrap(
              spacing: width * 0.02,
              runSpacing: width * 0.02,
              children: [
                ...sizesToShow.map(
                  (size) => GestureDetector(
                    onTap: () => onSizeSelected(size),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: width * 0.015,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedSize == size
                              ? Palette.blackColor
                              : Palette.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(
                          Constants.borderRadius(context),
                        ),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          fontSize: TextSizes.small(context),
                          color: Palette.blackColor,
                        ),
                      ),
                    ),
                  ),
                ),
                if (remaining > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: width * 0.015,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Palette.borderColor),
                      borderRadius: BorderRadius.circular(
                        Constants.borderRadius(context),
                      ),
                    ),
                    child: Text(
                      '+ $remaining more',
                      style: TextStyle(
                        fontSize: TextSizes.small(context),
                        color: Palette.mediumGreyColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: height * 0.02),

          // Buy now button
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: onBuyNow,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: height * 0.015),
              decoration: BoxDecoration(
                color: Palette.blackColor,
                borderRadius: BorderRadius.circular(
                  Constants.borderRadius(context),
                ),
              ),
              child: Center(
                child: Text(
                  'Buy now',
                  style: TextStyle(
                    color: Palette.whiteColor,
                    fontSize: TextSizes.medium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
