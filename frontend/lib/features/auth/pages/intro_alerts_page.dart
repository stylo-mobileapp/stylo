import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/auth/pages/auth_page.dart';

class IntroAlertsPage extends ConsumerWidget {
  final VoidCallback signInAsGuest;
  const IntroAlertsPage({super.key, required this.signInAsGuest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    List<Map<String, String>> alerts = [
      {
        "title": "Price Drop Alert",
        "body": "AIR ZOOM ALPHAFLY NEXT% 3 just dropped to €289.99 on BSTN",
        "imagePath": "images/alphafly.png",
      },
      {
        "title": "Back In Stock Alert",
        "body": "KNIT SWEAT PANTS - PUSHER PANTS is back in stock",
        "imagePath": "images/pants.png",
      },
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          horizontal: Constants.horizontalSpacing(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      ref.read(authPageIndexProvider.notifier).state = 1,
                  child: Icon(
                    CupertinoIcons.arrow_left,
                    size: Constants.iconSize(context),
                  ),
                ),
                Spacer(),
                Text(
                  "Stay in the Know",
                  style: TextStyle(fontSize: TextSizes.medium(context)),
                ),
                Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Icon(null, size: Constants.iconSize(context)),
                ),
              ],
            ),
            SizedBox(height: height * 0.04),
            Text(
              "Never miss a sale or a new drop from your favourite brands",
              style: TextStyle(
                fontSize: TextSizes.large(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: alerts
                  .map(
                    (e) => Container(
                      margin: EdgeInsets.only(top: height * 0.02),
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.015,
                        horizontal: Constants.horizontalSpacing(context),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Constants.borderRadius(context),
                        ),
                        color: Palette.whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: Palette.softGreyColor,
                            blurRadius: 5.0,
                            spreadRadius: 5.0,
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            width: width * 0.125,
                            height: width * 0.125,
                            decoration: BoxDecoration(
                              border: Border.all(color: Palette.borderColor),
                              borderRadius: BorderRadius.circular(
                                Constants.borderRadius(context),
                              ),
                              image: const DecorationImage(
                                image: AssetImage("images/stylo-logo.png"),
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.025),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e["title"]!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: TextSizes.small(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  e["body"]!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: TextSizes.small(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: width * 0.025),
                          Container(
                            width: width * 0.125,
                            height: width * 0.125,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Constants.borderRadius(context),
                              ),
                              image: DecorationImage(
                                image: AssetImage(e["imagePath"]!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            Spacer(),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: signInAsGuest,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                margin: EdgeInsets.only(bottom: height * 0.01),
                decoration: BoxDecoration(
                  color: Palette.blackColor,
                  borderRadius: BorderRadius.circular(
                    Constants.borderRadius(context),
                  ),
                ),
                child: Center(
                  child: Text(
                    "NEXT",
                    style: TextStyle(
                      fontSize: TextSizes.medium(context),
                      color: Palette.whiteColor,
                      fontWeight: FontWeight.bold,
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
