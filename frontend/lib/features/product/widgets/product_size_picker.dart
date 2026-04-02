import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/models/product.dart';

class ProductSizePicker extends StatelessWidget {
  final Product product;
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;

  const ProductSizePicker({
    super.key,
    required this.product,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  bool _isSizeAvailable(String size) {
    return product.availableSizes.contains(size);
  }

  void _show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _SizePickerSheet(
        product: product,
        selectedSize: selectedSize,
        onSizeSelected: (size) {
          onSizeSelected(size);
          Navigator.of(ctx).pop();
        },
        isSizeAvailable: _isSizeAvailable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    double width = Constants.width(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: () => _show(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.025,
          vertical: height * 0.02,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.borderColor),
          borderRadius: BorderRadius.circular(Constants.borderRadius(context)),
        ),
        child: Row(
          children: [
            Text(
              selectedSize ?? 'Select size to see best price',
              style: TextStyle(
                fontSize: TextSizes.medium(context),
                color: selectedSize != null
                    ? Palette.blackColor
                    : Palette.mediumGreyColor,
                fontWeight: selectedSize != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_down,
              size: Constants.iconSize(context) * 0.75,
            ),
          ],
        ),
      ),
    );
  }
}

class _SizePickerSheet extends StatelessWidget {
  final Product product;
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;
  final bool Function(String) isSizeAvailable;

  const _SizePickerSheet({
    required this.product,
    required this.selectedSize,
    required this.onSizeSelected,
    required this.isSizeAvailable,
  });

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    double spacing = Constants.horizontalSpacing(context);

    double sheetHeight = product.allSizes.length > 9
        ? height * 0.75
        : height * 0.6;

    return Container(
      width: width,
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Palette.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Constants.borderRadius(context) * 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle
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

            // Header: badge + title + close
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Available count badge
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(null, size: Constants.iconSize(context)),
                  ),
                  Text(
                    'SELECT SIZE',
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
                      color: Palette.blackColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),

            // Sizes grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: width * 0.025,
                    mainAxisSpacing: width * 0.025,
                    mainAxisExtent: height * 0.075,
                  ),
                  itemCount: product.allSizes.length,
                  itemBuilder: (context, index) {
                    final size = product.allSizes[index];
                    final isAvailable = isSizeAvailable(size);
                    final isSelected = selectedSize == size;

                    final variantPrice =
                        product.variants != null &&
                            product.variants!.containsKey(size)
                        ? product.variants![size]!.price
                        : product.price;

                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: isAvailable
                          ? () => onSizeSelected(size)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.whiteColor,
                          border: Border.all(
                            color: isSelected
                                ? Palette.blackColor
                                : isAvailable
                                ? Palette.borderColor
                                : Palette.softGreyColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            Constants.borderRadius(context),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    size,
                                    style: TextStyle(
                                      fontSize: TextSizes.medium(context),
                                      fontWeight: !isAvailable
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: !isAvailable
                                          ? Palette.mediumGreyColor
                                          : Palette.blackColor,
                                    ),
                                  ),
                                  if (isAvailable)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: height * 0.0025,
                                      ),
                                      child: Text(
                                        '$variantPrice €',
                                        style: TextStyle(
                                          fontSize: TextSizes.medium(context),
                                          color: Palette.mediumGreyColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (!isAvailable)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _StrikethroughPainter(
                                    color: Palette.borderColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom disclaimer bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing,
                vertical: height * 0.015,
              ),
              decoration: BoxDecoration(
                color: Palette.backgroundColor,
                border: Border(top: BorderSide(color: Palette.borderColor)),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    size: Constants.iconSize(context),
                    color: Palette.mediumGreyColor,
                  ),
                  SizedBox(width: width * 0.015),
                  Expanded(
                    child: Text(
                      'Products are sourced from different stores. Sizing conventions may vary.',
                      style: TextStyle(
                        fontSize: TextSizes.small(context),
                        color: Palette.mediumGreyColor,
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

class _StrikethroughPainter extends CustomPainter {
  final Color color;
  _StrikethroughPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
