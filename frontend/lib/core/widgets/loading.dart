import 'package:flutter/cupertino.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const CupertinoActivityIndicator());
  }
}
