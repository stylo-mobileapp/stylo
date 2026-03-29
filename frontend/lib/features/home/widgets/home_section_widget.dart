import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/home/controller/home_providers.dart';
import 'package:frontend/features/home/widgets/product_card.dart';
import 'package:frontend/models/home_section.dart';
import 'package:frontend/models/product_summary.dart';

class HomeSectionWidget extends ConsumerWidget {
  final HomeSection section;
  final bool isFirst;

  const HomeSectionWidget({
    super.key,
    required this.section,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<ProductSummary>> asyncProducts;

    switch (section.type) {
      case HomeSectionType.recentlyViewed:
        asyncProducts = ref.watch(recentlyViewedProductsProvider);
        break;
      case HomeSectionType.discounted:
        asyncProducts = ref.watch(discountedProductsProvider);
        break;
      case HomeSectionType.brand:
        if (section.brandQuery == null) {
          asyncProducts = const AsyncValue.data([]);
        } else {
          asyncProducts = ref.watch(brandProductsProvider(section.brandQuery!));
        }
        break;
    }

    return asyncProducts.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return _buildContent(context, products);
      },
      loading: () => _buildContent(context, null),
      error: (e, st) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(BuildContext context, List<ProductSummary>? products) {
    double height = Constants.height(context);
    double horizontalPadding = Constants.horizontalSpacing(context);

    return Column(
      children: [
        SizedBox(height: height * 0.02),
        Container(height: height * 0.005, color: Palette.softGreyColor),
        SizedBox(height: height * 0.03),
        Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Center(
                child: Text(
                  section.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: TextSizes.extraLarge(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (section.subtitle.isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: height * 0.01),
                    Center(
                      child: Text(
                        section.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: TextSizes.medium(context),
                          color: Palette.mediumGreyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: height * 0.03),
              if (isFirst && (products == null || products.length >= 5))
                _buildMosaicGrid(context, products)
              else
                _buildStandardGrid(context, products),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageBlock(BuildContext context, ProductSummary? product) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.softGreyColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius(context)),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: Palette.borderColor),
        borderRadius: BorderRadius.circular(Constants.borderRadius(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: product == null
          ? const SizedBox()
          : CachedNetworkImage(
              imageUrl: product.imageUrl,
              errorWidget: (context, url, error) => const SizedBox(),
              placeholder: (context, url) => const SizedBox(),
            ),
    );
  }

  Widget _buildMosaicGrid(
    BuildContext context,
    List<ProductSummary>? products,
  ) {
    double height = Constants.height(context);
    double spacing = Constants.horizontalSpacing(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = (totalWidth - 2 * spacing) / 3;
        final largeItemWidth = (itemWidth * 2) + spacing;
        final smallItemHeight = ((height * 0.35) - spacing) / 2;

        return Column(
          children: [
            SizedBox(
              height: height * 0.35,
              child: Row(
                children: [
                  // Large left image
                  SizedBox(
                    height: height * 0.35,
                    width: largeItemWidth,
                    child: _buildImageBlock(context, products?[0]),
                  ),
                  SizedBox(width: spacing),
                  // Two small right images stacked
                  SizedBox(
                    width: itemWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          height: smallItemHeight,
                          width: double.infinity,
                          child: _buildImageBlock(context, products?[1]),
                        ),
                        SizedBox(height: spacing),
                        SizedBox(
                          height: smallItemHeight,
                          width: double.infinity,
                          child: _buildImageBlock(context, products?[2]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            // Bottom 3 equal images
            Row(
              children: [
                for (
                  int i = 3;
                  i < 6 && (products == null || i < products.length);
                  i++
                ) ...[
                  if (i > 3) SizedBox(width: spacing),
                  SizedBox(
                    width: itemWidth,
                    height: smallItemHeight,
                    child: _buildImageBlock(context, products?[i]),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCardSkeleton(BuildContext context) {
    double width = Constants.width(context);
    double height = Constants.height(context);
    double spacing = Constants.horizontalSpacing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: (width - 3 * spacing) / 2,
          height: (width - 3 * spacing) / 2,
          decoration: BoxDecoration(
            color: Palette.softGreyColor,
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
        ),
        SizedBox(height: height * 0.01),
        Container(
          height: height * 0.016,
          width: width * 0.22,
          decoration: BoxDecoration(
            color: Palette.softGreyColor,
            borderRadius: BorderRadius.circular(
              Constants.borderRadius(context) / 2,
            ),
          ),
        ),
        SizedBox(height: height * 0.005),
        Container(
          height: height * 0.014,
          width: width * 0.16,
          decoration: BoxDecoration(
            color: Palette.softGreyColor,
            borderRadius: BorderRadius.circular(
              Constants.borderRadius(context) / 2,
            ),
          ),
        ),
        SizedBox(height: height * 0.005),
        Container(
          height: height * 0.014,
          width: width * 0.28,
          decoration: BoxDecoration(
            color: Palette.softGreyColor,
            borderRadius: BorderRadius.circular(
              Constants.borderRadius(context) / 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardGrid(
    BuildContext context,
    List<ProductSummary>? products,
  ) {
    double spacing = Constants.horizontalSpacing(context);

    if (products == null) {
      List<Widget> rows = [];
      for (int i = 0; i < 4; i += 2) {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildProductCardSkeleton(context)),
              SizedBox(width: spacing),
              Expanded(child: _buildProductCardSkeleton(context)),
            ],
          ),
        );
        rows.add(SizedBox(height: spacing * 1.5));
      }
      return Column(children: rows);
    }

    List<Widget> rows = [];
    for (int i = 0; i < products.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ProductCard(product: products[i])),
            SizedBox(width: spacing),
            if (i + 1 < products.length)
              Expanded(child: ProductCard(product: products[i + 1]))
            else
              Expanded(child: const SizedBox()),
          ],
        ),
      );
      if (i + 2 < products.length) {
        rows.add(SizedBox(height: spacing * 1.5));
      }
    }

    return Column(children: rows);
  }
}
