import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/navigation_page.dart';
import 'package:frontend/features/home/controller/home_controller.dart';
import 'package:frontend/features/home/controller/home_providers.dart';
import 'package:frontend/features/home/widgets/home_section_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static final scrollController = ScrollController();

  static void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeControllerProvider.notifier).loadHomeSections(),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    final homeSections = ref.watch(homeControllerProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.bell,
                          size: Constants.iconSize(context),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "STYLO",
                        style: TextStyle(
                          fontSize: TextSizes.large(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.person,
                          size: Constants.iconSize(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        ref.read(navigationPageIndexProvider.notifier).state =
                            1,
                    child: AbsorbPointer(
                      child: CupertinoSearchTextField(
                        placeholder: "Search (e.g 'Asics Novablast 4')",
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                ],
              ),
            ),
            Expanded(
              child: homeSections.when(
                data: (data) => CustomScrollView(
                  controller: HomePage.scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        ref.invalidate(brandProductsProvider);
                        ref.invalidate(recentlyViewedProductsProvider);
                        ref.invalidate(discountedProductsProvider);
                        await ref
                            .read(homeControllerProvider.notifier)
                            .loadHomeSections();
                      },
                      builder:
                          (
                            context,
                            refreshState,
                            pulledExtent,
                            refreshTriggerPullDistance,
                            refreshIndicatorExtent,
                          ) {
                            final double percentage =
                                (pulledExtent / refreshIndicatorExtent).clamp(
                                  0.0,
                                  1.0,
                                );

                            return Transform.scale(
                              scale: refreshState == RefreshIndicatorMode.drag
                                  ? Curves.easeOut.transform(percentage)
                                  : 1.0,
                              child: Opacity(
                                opacity:
                                    refreshState == RefreshIndicatorMode.drag
                                    ? percentage
                                    : 1.0,
                                child: const Loading(),
                              ),
                            );
                          },
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => HomeSectionWidget(
                          section: data[index],
                          isFirst: index == 0,
                        ),
                        childCount: data.length,
                      ),
                    ),
                  ],
                ),
                error: (error, stackTrace) => SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constants.horizontalSpacing(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Something went wrong.\nPlease check your connection and try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.mediumGreyColor,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => ref
                              .read(homeControllerProvider.notifier)
                              .loadHomeSections(),
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
                loading: () => const Loading(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
