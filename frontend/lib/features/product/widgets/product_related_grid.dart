import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/home/widgets/product_card.dart';
import 'package:frontend/features/product/controller/product_controller.dart';
import 'package:frontend/models/product.dart';

class ProductRelatedGrid extends ConsumerWidget {
  final Product product;
  final GlobalKey moreLikeThisKey;

  const ProductRelatedGrid({
    super.key,
    required this.product,
    required this.moreLikeThisKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    double spacing = Constants.horizontalSpacing(context);
    final asyncRelated = ref.watch(relatedProductsProvider(product));

    return SliverMainAxisGroup(
      slivers: [
        // Title
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More like this',
                  key: moreLikeThisKey,
                  style: TextStyle(
                    fontSize: TextSizes.extraLarge(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),

        // Grid
        asyncRelated.when(
          data: (products) {
            if (products.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  int i = index * 2;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < (products.length / 2).ceil() - 1
                          ? spacing * 1.5
                          : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: ProductCard(product: products[i])),
                        SizedBox(width: spacing),
                        if (i + 1 < products.length)
                          Expanded(child: ProductCard(product: products[i + 1]))
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  );
                }, childCount: (products.length / 2).ceil()),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: Loading()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }
}
