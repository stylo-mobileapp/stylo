import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/auth/pages/auth_page.dart';

class SetGenderPage extends ConsumerWidget {
  const SetGenderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);
    List<String> genders = ["MENSWEAR", "WOMENSWEAR"];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.horizontalSpacing(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Icon(null, size: Constants.iconSize(context)),
                ),
                Spacer(),
                Text(
                  "Tailor your app experience",
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
              "Set your shopping preference",
              style: TextStyle(
                fontSize: TextSizes.extraLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              "Don't worry: you'll be able to change it whenever you want to in your Stylo account.",
              style: TextStyle(
                fontSize: TextSizes.medium(context),
                color: Palette.mediumGreyColor,
              ),
            ),
            Spacer(),
            Column(
              children: genders
                  .map(
                    (e) => CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ref.read(authGenderProvider.notifier).state = e;
                        ref.read(authPageIndexProvider.notifier).state = 1;
                      },
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
                            "SHOP $e",
                            style: TextStyle(
                              fontSize: TextSizes.medium(context),
                              color: Palette.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Center(
              child: Text(
                "You can change this later in the 'account'.",
                style: TextStyle(
                  fontSize: TextSizes.small(context),
                  color: Palette.mediumGreyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
