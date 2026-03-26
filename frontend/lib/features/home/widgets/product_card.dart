import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/models/product_summary.dart';

class ProductCard extends StatelessWidget {
  final ProductSummary product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    double spacing = Constants.horizontalSpacing(context);

    return Column(
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
    );
  }
}
