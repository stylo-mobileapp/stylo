import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/features/search/pages/search_page.dart';
import 'package:frontend/features/wishlist/pages/wishlist_page.dart';

final navigationPageIndexProvider = StateProvider<int>((ref) => 0);

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key});

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationPageIndexProvider);
    double width = Constants.width(context);
    double height = Constants.height(context);

    return CupertinoPageScaffold(
      backgroundColor: Palette.backgroundColor,
      child: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: [HomePage(), SearchPage(), WishlistPage()],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: height * 0.04,
                top: height * 0.03,
                left: 2 * Constants.horizontalSpacing(context),
                right: 2 * Constants.horizontalSpacing(context),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Palette.backgroundColor,
                    Palette.backgroundColor.withValues(alpha: 0.9),
                    Palette.backgroundColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.0175,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.whiteColor,
                    borderRadius: BorderRadius.circular(
                      3 * Constants.borderRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.blackColor.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        context,
                        CupertinoIcons.house,
                        CupertinoIcons.house_fill,
                        "Home",
                        0,
                        currentIndex,
                      ),
                      _buildNavItem(
                        context,
                        CupertinoIcons.search,
                        CupertinoIcons.search,
                        "Search",
                        1,
                        currentIndex,
                      ),
                      _buildNavItem(
                        context,
                        CupertinoIcons.heart,
                        CupertinoIcons.heart_fill,
                        "Wishlist",
                        2,
                        currentIndex,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    int currentIndex,
  ) {
    double width = Constants.width(context);
    double height = Constants.height(context);
    final isSelected = currentIndex == index;
    final color = isSelected ? Palette.primaryColor : Palette.mediumGreyColor;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        ref.read(navigationPageIndexProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? width * 0.04 : width * 0.03,
          vertical: height * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Palette.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            3 * Constants.borderRadius(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: Constants.iconSize(context),
            ),
            if (isSelected) ...[
              SizedBox(width: width * 0.015),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: TextSizes.small(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
