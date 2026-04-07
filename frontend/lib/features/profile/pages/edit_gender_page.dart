import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/features/profile/controller/profile_controller.dart';
import 'package:frontend/features/profile/widgets/profile_list_item.dart';

class EditGenderPage extends ConsumerWidget {
  const EditGenderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final currentGender = userProfile?.gender ?? 'Men';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: Constants.horizontalSpacing(context),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.arrow_left,
            size: Constants.iconSize(context),
          ),
        ),
        middle: Text(
          'Search for',
          style: TextStyle(
            fontSize: TextSizes.medium(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.horizontalSpacing(context),
          ),
          child: Column(
            children: [
              ProfileListItem(
                title: 'Men',
                trailingIcon: currentGender == 'Men'
                    ? CupertinoIcons.check_mark
                    : null,
                onTap: () {
                  ref
                      .read(profileControllerProvider.notifier)
                      .updateGender(context: context, gender: 'Men');
                  Navigator.pop(context);
                },
              ),
              ProfileListItem(
                title: 'Women',
                trailingIcon: currentGender == 'Women'
                    ? CupertinoIcons.check_mark
                    : null,
                onTap: () {
                  ref
                      .read(profileControllerProvider.notifier)
                      .updateGender(context: context, gender: 'Women');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
