import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/product/widgets/product_image_viewer.dart';

class ProductImageSection extends StatelessWidget {
  final String imageUrl;
  final bool hasDiscount;

  const ProductImageSection({
    super.key,
    required this.imageUrl,
    required this.hasDiscount,
  });

  @override
  Widget build(BuildContext context) {
    double width = Constants.width(context);
    double height = Constants.height(context);
    double spacing = Constants.horizontalSpacing(context);

    return GestureDetector(
      onTap: () => ProductImageViewer.show(context, imageUrl),
      child: Stack(
        children: [
          SizedBox(
            width: width,
            height: width,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => const SizedBox(),
              placeholder: (context, url) => const SizedBox(),
            ),
          ),
          if (hasDiscount)
            Positioned(
              left: spacing,
              bottom: height * 0.02,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing * 1.5,
                  vertical: spacing * 0.75,
                ),
                decoration: BoxDecoration(
                  color: Palette.blackColor,
                  borderRadius: BorderRadius.circular(
                    Constants.borderRadius(context),
                  ),
                ),
                child: Text(
                  'On sale',
                  style: TextStyle(
                    color: Palette.whiteColor,
                    fontSize: TextSizes.small(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
