import 'package:flutter/cupertino.dart';
import 'package:frontend/core/widgets/loading.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: Loading());
  }
}
