import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';

class ProductImageViewer extends StatefulWidget {
  final String imageUrl;

  const ProductImageViewer({super.key, required this.imageUrl});

  static void show(BuildContext context, String imageUrl) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProductImageViewer(imageUrl: imageUrl);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  final TransformationController _transformController =
      TransformationController();
  double _opacity = 1.0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    // Only allow drag dismiss when not zoomed in
    if (_transformController.value.isIdentity()) {
      setState(() => _isDragging = true);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += details.delta;
      // Fade background based on vertical drag distance
      final progress = (_dragOffset.dy.abs() / 300).clamp(0.0, 1.0);
      _opacity = 1.0 - progress;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    if (_dragOffset.dy.abs() > 100 ||
        details.velocity.pixelsPerSecond.dy.abs() > 500) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _opacity = 1.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double spacing = Constants.horizontalSpacing(context);

    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: AnimatedContainer(
        duration: _isDragging
            ? Duration.zero
            : const Duration(milliseconds: 200),
        color: Palette.blackColor.withValues(alpha: _opacity),
        child: Stack(
          children: [
            // Zoomable image
            Center(
              child: Transform.translate(
                offset: _dragOffset,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => const SizedBox(),
                      placeholder: (context, url) => const Center(
                        child: CupertinoActivityIndicator(
                          color: Palette.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header: counter + close
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 100),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Image counter
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing * 0.8,
                            vertical: spacing * 0.4,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.blackColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(
                              Constants.borderRadius(context) / 2,
                            ),
                          ),
                          child: Text(
                            '1/1',
                            style: TextStyle(
                              color: Palette.whiteColor,
                              fontSize: TextSizes.small(context),
                            ),
                          ),
                        ),

                        // Close button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(spacing * 0.5),
                            decoration: BoxDecoration(
                              color: Palette.blackColor.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              color: Palette.whiteColor,
                              size: Constants.iconSize(context) * 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
