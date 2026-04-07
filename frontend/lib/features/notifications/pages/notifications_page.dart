import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/notifications/controller/notifications_controller.dart';
import 'package:frontend/features/notifications/widgets/notification_item.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = Constants.height(context);
    final notificationsState = ref.watch(notificationsControllerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: Constants.horizontalSpacing(context),
        ),
        middle: Text(
          'Notifications',
          style: TextStyle(
            fontSize: TextSizes.medium(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.xmark,
            color: Palette.blackColor,
            size: Constants.iconSize(context),
          ),
        ),
        border: const Border(bottom: BorderSide.none),
      ),
      child: SafeArea(
        child: notificationsState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState(context, height);
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .loadNotifications(),
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
                            opacity: refreshState == RefreshIndicatorMode.drag
                                ? percentage
                                : 1.0,
                            child: const Loading(),
                          ),
                        );
                      },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return NotificationItem(
                      notification: notifications[index],
                      isLast: index == notifications.length - 1,
                    );
                  }, childCount: notifications.length),
                ),
              ],
            );
          },
          error: (error, st) => SizedBox(
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
                    "Something went wrong.\nPlease try again later.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: TextSizes.medium(context),
                      color: Palette.mediumGreyColor,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        ref.invalidate(notificationsControllerProvider),
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
    );
  }

  Widget _buildEmptyState(BuildContext context, double height) {
    double width = Constants.width(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constants.horizontalSpacing(context) * 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.04),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.bell_fill,
                size: Constants.iconSize(context) * 1.5,
                color: Palette.blackColor,
              ),
              SizedBox(width: width * 0.025),
              Expanded(
                child: Text(
                  "We can't find any updates on your tracked items right now",
                  style: TextStyle(fontSize: TextSizes.large(context)),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.02),
          Text(
            "We'll notify you when any of your tracked items drop in price or come back in stock. Make sure you have notifications turned on to be in the know right away.",
            style: TextStyle(
              fontSize: TextSizes.medium(context),
              color: Palette.mediumGreyColor,
            ),
          ),
        ],
      ),
    );
  }
}
