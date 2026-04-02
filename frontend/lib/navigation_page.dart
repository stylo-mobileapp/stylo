import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/constants/constants.dart';
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
  late final CupertinoTabController _tabController;
  final List<GlobalKey<NavigatorState>> _tabNavigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(
      initialIndex: ref.read(navigationPageIndexProvider),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);

    ref.listen<int>(navigationPageIndexProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.index = next;
      }
    });

    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        activeColor: Palette.blackColor,
        height: height * 0.07,
        iconSize: Constants.iconSize(context),
        onTap: (index) {
          final currentIndex = ref.read(navigationPageIndexProvider);
          if (currentIndex == index) {
            // Pop to root first, then scroll to top if already at root
            final navigatorState = _tabNavigatorKeys[index].currentState;
            if (navigatorState != null && navigatorState.canPop()) {
              navigatorState.popUntil((route) => route.isFirst);
            } else if (index == 0) {
              HomePage.scrollToTop();
            }
          } else {
            ref.read(navigationPageIndexProvider.notifier).state = index;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            activeIcon: Icon(CupertinoIcons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            activeIcon: Icon(CupertinoIcons.heart_fill),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          navigatorKey: _tabNavigatorKeys[index],
          builder: (context) {
            switch (index) {
              case 0:
                return const HomePage();
              case 1:
                return const SearchPage();
              case 2:
                return const WishlistPage();
              default:
                return const HomePage();
            }
          },
        );
      },
    );
  }
}
