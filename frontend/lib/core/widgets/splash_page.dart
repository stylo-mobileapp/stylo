import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/features/home/controller/home_controller.dart';
import 'package:frontend/navigation_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _preloadAndNavigate();
  }

  Future<void> _preloadAndNavigate() async {
    // Start loading home data immediately
    final loadFuture = ref
        .read(homeControllerProvider.notifier)
        .loadHomeSections();

    // Ensure a minimum splash duration for branding
    final minDuration = Future.delayed(const Duration(milliseconds: 1500));

    // Wait for both: data loaded AND minimum time elapsed
    await Future.wait([loadFuture, minDuration]);

    _navigate();
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const NavigationPage(),
        transitionsBuilder: (_, animation, a, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Palette.backgroundColor,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset('images/stylo-logo.png'),
        ),
      ),
    );
  }
}
