import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/core/secrets/secrets.dart';
import 'package:frontend/core/services/fcm_service.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/widgets/auth_error_page.dart';
import 'package:frontend/core/widgets/loading_page.dart';
import 'package:frontend/features/auth/controller/auth_controller.dart';
import 'package:frontend/features/auth/pages/auth_page.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/navigation_page.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.ios);

  await Supabase.initialize(
    url: SupabaseSecrets.url,
    anonKey: SupabaseSecrets.key,
  );

  final container = ProviderContainer();
  container.read(sharedPreferencesProvider).init();

  runApp(
    OverlaySupport.global(
      child: UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    initFcmIfLoggedIn();
  }

  Future<void> initFcmIfLoggedIn() async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId != null) {
      try {
        await ref.read(fcmServiceProvider).initFcm(userId);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorKey: navigatorKey,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: "Stylo",
      theme: Theme.themeMode(),
      home: ref
          .watch(authStateProvider)
          .when(
            data: (data) {
              if (data.session == null) {
                return AuthPage();
              }

              return NavigationPage();
            },
            error: (error, stackTrace) =>
                AuthErrorPage(message: error.toString()),
            loading: () => LoadingPage(),
          ),
    );
  }
}
