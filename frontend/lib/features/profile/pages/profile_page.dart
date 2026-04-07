import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/profile/widgets/profile_list_item.dart';
import 'package:frontend/features/profile/controller/profile_controller.dart';
import 'package:frontend/features/profile/pages/edit_gender_page.dart';
import 'package:frontend/features/profile/pages/edit_brands_page.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _shareApp() {
    Share.share('Stylo: Shop and Save');
  }

  Future<void> _leaveFeedback() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: '6758734420');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    final userProfile = ref.watch(userProfileProvider).value;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: Constants.horizontalSpacing(context),
        ),
        middle: Text(
          'Account',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalSpacing(context),
            ),
            child: Column(
              children: [
                SizedBox(height: height * 0.01),
                Container(
                  width: width * 0.25,
                  height: width * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Palette.softGreyColor,
                  ),
                  child: Center(
                    child: Text(
                      ref
                          .read(supabaseClientProvider)
                          .auth
                          .currentUser!
                          .id
                          .substring(0, 2)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: TextSizes.title(context),
                        fontWeight: FontWeight.bold,
                        color: Palette.whiteColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  ref
                      .read(supabaseClientProvider)
                      .auth
                      .currentUser!
                      .id
                      .split('-')[0],
                  style: TextStyle(
                    fontSize: TextSizes.medium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  userProfile != null
                      ? "Stylo member since ${DateFormat("MMM ''yy").format(userProfile.createdAt)}"
                      : "Stylo member since",
                  style: TextStyle(
                    fontSize: TextSizes.small(context),
                    color: Palette.mediumGreyColor,
                  ),
                ),
                SizedBox(height: height * 0.02),
                ProfileListItem(
                  title: 'Search for',
                  trailingText: userProfile?.gender ?? "Men",
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const EditGenderPage(),
                      ),
                    );
                  },
                ),
                ProfileListItem(
                  title: 'Favorite brands',
                  trailingText: userProfile != null
                      ? "${userProfile.brands.length} selected"
                      : "0 selected",
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const EditBrandsPage(),
                      ),
                    );
                  },
                ),
                ProfileListItem(
                  title: 'Share the app',
                  onTap: () => _shareApp(),
                ),
                ProfileListItem(
                  title: 'Leave feedback',
                  onTap: () => _leaveFeedback(),
                ),
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: width * 0.1,
                      height: width * 0.1,
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
                    Text(
                      ref
                          .watch(packageInfoProvider)
                          .when(
                            data: (info) =>
                                'v${info.version} - Build ${info.buildNumber}',
                            error: (e, s) => 'v1.0.0',
                            loading: () => 'v...',
                          ),
                      style: TextStyle(
                        fontSize: TextSizes.medium(context),
                        color: Palette.mediumGreyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
