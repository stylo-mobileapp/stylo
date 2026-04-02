import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/features/product/pages/brand_products_page.dart';

class ProductDetailsSection extends StatefulWidget {
  final Product product;
  final String? selectedSize;

  const ProductDetailsSection({
    super.key,
    required this.product,
    this.selectedSize,
  });

  @override
  State<ProductDetailsSection> createState() => _ProductDetailsSectionState();
}

class _ProductDetailsSectionState extends State<ProductDetailsSection> {
  bool _expanded = false;

  String _buildDetailsText() {
    final product = widget.product;
    final buffer = StringBuffer();
    buffer.writeln(
      'Get your ${product.title} for ${product.price} EUR at ${product.source}.',
    );
    buffer.writeln('Brand: ${product.brand}');
    buffer.writeln('Category: ${product.category}');
    if (product.sku != null) {
      buffer.writeln('SKU: ${product.sku}');
    }
    if (widget.selectedSize != null) {
      buffer.writeln('Size: ${widget.selectedSize}');
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);

    return Column(
      children: [
        // Product details toggle
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: height * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Palette.borderColor)),
            ),
            child: Row(
              children: [
                Text(
                  'Product details',
                  style: TextStyle(
                    fontSize: TextSizes.medium(context),
                    color: Palette.blackColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: Constants.iconSize(context) * 0.75,
                  color: Palette.blackColor,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.02),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _buildDetailsText(),
                style: TextStyle(
                  fontSize: TextSizes.small(context),
                  color: Palette.mediumGreyColor,
                ),
              ),
            ),
          ),
        ],

        // Shop more from brand
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) =>
                    BrandProductsPage(brand: widget.product.brand),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: height * 0.02),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Palette.borderColor),
                bottom: BorderSide(color: Palette.borderColor),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Shop more from ${widget.product.brand}',
                  style: TextStyle(
                    fontSize: TextSizes.medium(context),
                    color: Palette.blackColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: Constants.iconSize(context) * 0.75,
                  color: Palette.blackColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
