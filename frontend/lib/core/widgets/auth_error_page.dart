import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/utils/show_error_dialog.dart';
import 'package:frontend/features/auth/controller/auth_controller.dart';

class AuthErrorPage extends ConsumerWidget {
  final String message;
  const AuthErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = Constants.height(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.horizontalSpacing(context),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => showErrorDialog(context, message),
                  child: Icon(
                    CupertinoIcons.question,
                    size: Constants.iconSize(context),
                  ),
                ),
              ),
              Spacer(),
              Text(
                "Unexpected error occurred",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TextSizes.title(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                "Authentication failed. Please try again or contact support if the problem persists.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TextSizes.large(context),
                  color: Palette.mediumGreyColor,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => ref.refresh(authStateProvider),
                child: Text(
                  "Try again",
                  style: TextStyle(
                    fontSize: TextSizes.medium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
