import 'package:flutter/cupertino.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';

void showErrorDialog(BuildContext context, String message) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(
        "Error",
        style: TextStyle(fontSize: TextSizes.medium(context)),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: TextSizes.medium(context)),
      ),
      actions: [
        CupertinoDialogAction(
          child: Text(
            "Close",
            style: TextStyle(fontSize: TextSizes.medium(context)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
