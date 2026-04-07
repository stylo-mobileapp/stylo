import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/auth/controller/auth_controller.dart';
import 'package:frontend/features/auth/pages/intro_alerts_page.dart';
import 'package:frontend/features/auth/pages/select_brands_page.dart';
import 'package:frontend/features/auth/pages/set_gender_page.dart';

final authPageIndexProvider = StateProvider((ref) => 0);

final authGenderProvider = StateProvider((ref) => "MENSWEAR");

final authBrandsProvider = StateProvider<List<String>>((ref) => []);

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  void signInAsGuest(BuildContext context, WidgetRef ref) async {
    ref
        .read(authControllerProvider.notifier)
        .signInAsGuest(
          context: context,
          gender: ref.read(authGenderProvider) == "MENSWEAR" ? "Men" : "Women",
          brands: ref.read(authBrandsProvider),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoading = ref.watch(authControllerProvider);
    int pageIndex = ref.watch(authPageIndexProvider);

    return CupertinoPageScaffold(
      child: isLoading
          ? Loading()
          : pageIndex == 0
          ? SetGenderPage()
          : pageIndex == 1
          ? SelectBrandsPage()
          : IntroAlertsPage(signInAsGuest: () => signInAsGuest(context, ref)),
    );
  }
}
