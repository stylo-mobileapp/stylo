import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);

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
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.person,
                          size: Constants.iconSize(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  AbsorbPointer(
                    child: CupertinoSearchTextField(
                      placeholder: "Search (e.g 'Asics Novablast 4')",
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Palette.borderColor)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ).copyWith(top: height * 0.03),
              margin: EdgeInsets.only(top: height * 0.02),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "From Your Recent Activity",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: TextSizes.extraLarge(context)),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Center(
                    child: Text(
                      "Based on your views",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: TextSizes.medium(context),
                        color: Palette.mediumGreyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
