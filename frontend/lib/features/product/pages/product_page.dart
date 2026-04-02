import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/product/controller/product_controller.dart';
import 'package:frontend/features/product/widgets/product_details_section.dart';
import 'package:frontend/features/product/widgets/product_image_section.dart';
import 'package:frontend/features/product/widgets/product_info_section.dart';
import 'package:frontend/features/product/widgets/product_price_section.dart';
import 'package:frontend/features/product/widgets/product_related_grid.dart';
import 'package:frontend/features/product/widgets/product_size_picker.dart';
import 'package:frontend/models/product.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductPage({super.key, required this.productId});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  String? _selectedSize;
  final GlobalKey _moreLikeThisKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToMoreLikeThis() {
    final keyContext = _moreLikeThisKey.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  double? _getPriceForSize(Product product) {
    if (_selectedSize == null) return null;
    if (product.variants != null &&
        product.variants!.containsKey(_selectedSize)) {
      return product.variants![_selectedSize]!.price;
    }
    return product.price;
  }

  Future<void> _openProductUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProduct = ref.watch(productProvider(widget.productId));

    return CupertinoPageScaffold(
      child: asyncProduct.when(
        data: (product) => _buildContent(context, product),
        loading: () => const SafeArea(child: Loading()),
        error: (error, st) => SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Couldn't load product.\nPlease try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: TextSizes.medium(context),
                    color: Palette.mediumGreyColor,
                  ),
                ),
                CupertinoButton(
                  onPressed: () =>
                      ref.invalidate(productProvider(widget.productId)),
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
    );
  }

  Widget _buildContent(BuildContext context, Product product) {
    double height = Constants.height(context);
    double spacing = Constants.horizontalSpacing(context);

    final hasDiscount = product.discountPercentage > 0;
    final displayPrice = _getPriceForSize(product) ?? product.price;

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Safe area top padding
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.top),
            ),

            // Product image
            SliverToBoxAdapter(
              child: ProductImageSection(
                imageUrl: product.imageUrl,
                hasDiscount: hasDiscount,
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info: see more, brand, title, wishlist
                    ProductInfoSection(
                      product: product,
                      onSeeMoreLikeThis: _scrollToMoreLikeThis,
                    ),

                    SizedBox(height: height * 0.02),

                    // Size selector
                    ProductSizePicker(
                      product: product,
                      selectedSize: _selectedSize,
                      onSizeSelected: (size) =>
                          setState(() => _selectedSize = size),
                    ),

                    SizedBox(height: height * 0.02),

                    // Price + buy now
                    ProductPriceSection(
                      product: product,
                      displayPrice: displayPrice,
                      hasDiscount: hasDiscount,
                      selectedSize: _selectedSize,
                      onSizeSelected: (size) =>
                          setState(() => _selectedSize = size),
                      onBuyNow: () => _openProductUrl(product.url),
                    ),

                    SizedBox(height: height * 0.03),

                    // Details + shop more
                    ProductDetailsSection(
                      product: product,
                      selectedSize: _selectedSize,
                    ),

                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ),

            // Related products
            ProductRelatedGrid(
              product: product,
              moreLikeThisKey: _moreLikeThisKey,
            ),

            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),

        // Floating back button
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    context,
                    icon: CupertinoIcons.arrow_left,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    double size = Constants.iconSize(context) * 1.8;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Palette.whiteColor.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Palette.blackColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: Constants.iconSize(context) * 0.9,
          color: Palette.blackColor,
        ),
      ),
    );
  }
}
