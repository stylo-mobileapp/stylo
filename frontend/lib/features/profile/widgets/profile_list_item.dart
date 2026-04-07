import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';

class ProfileListItem extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  const ProfileListItem({
    super.key,
    required this.title,
    this.trailingText,
    required this.onTap,
    this.trailingIcon = CupertinoIcons.arrow_right,
  });

  @override
  Widget build(BuildContext context) {
    double width = Constants.width(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Constants.height(context) * 0.025,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: TextSizes.medium(context),
                color: Palette.blackColor,
              ),
            ),
            const Spacer(),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(
                  fontSize: TextSizes.small(context),
                  color: Palette.mediumGreyColor,
                ),
              ),
              SizedBox(width: width * 0.02),
            ],
            if (trailingIcon != null) ...[
              Icon(
                trailingIcon,
                size: Constants.iconSize(context) * 0.75,
                color: Palette.blackColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
