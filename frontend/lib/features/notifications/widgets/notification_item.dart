import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final bool isLast;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.isLast,
  });

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = Constants.height(context);
    final width = Constants.width(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: notification.url != null
          ? () async {
              final uri = Uri.parse(notification.url!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.horizontalSpacing(context),
          vertical: height * 0.02,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Palette.borderColor),
            bottom: isLast
                ? BorderSide(color: Palette.borderColor)
                : BorderSide.none,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.imageUrl != null)
              Container(
                width: width * 0.25,
                height: width * 0.25,
                decoration: BoxDecoration(
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
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: notification.imageUrl!,
                  errorWidget: (context, url, error) => SizedBox(),
                  placeholder: (context, url) => SizedBox(),
                ),
              ),
            SizedBox(width: width * 0.025),
            Expanded(
              child: SizedBox(
                height: width * 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.025,
                            vertical: height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.blackColor,
                            borderRadius: BorderRadius.circular(
                              Constants.borderRadius(context),
                            ),
                          ),
                          child: Text(
                            notification.type == "price_drop"
                                ? "Better price"
                                : "Back in stock",
                            style: TextStyle(
                              color: Palette.whiteColor,
                              fontSize: TextSizes.small(context),
                            ),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: TextStyle(
                            color: Palette.mediumGreyColor,
                            fontSize: TextSizes.extraSmall(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      notification.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Palette.blackColor,
                        fontSize: TextSizes.small(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
