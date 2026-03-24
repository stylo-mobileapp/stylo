import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

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
                        "Search",
                        style: TextStyle(
                          fontSize: TextSizes.medium(context),
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
          ],
        ),
      ),
    );
  }
}
