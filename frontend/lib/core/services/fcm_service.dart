import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final fcmServiceProvider = Provider(
  (ref) => FcmService(ref.read(supabaseClientProvider)),
);

class FcmService {
  final SupabaseClient supabaseClient;
  StreamSubscription<String>? tokenRefreshSubscription;

  FcmService(this.supabaseClient);

  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future<void> saveTokenToSupabase(String userId, String token) async {
    await supabaseClient.rpc(
      'upsert_fcm_token',
      params: {'p_user_id': userId, 'p_token': token},
    );
  }

  Future<void> initFcm(String userId) async {
    await requestPermission();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    final token = await getToken();
    if (token != null) {
      await saveTokenToSupabase(userId, token);
    }

    tokenRefreshSubscription?.cancel();
    tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) {
        saveTokenToSupabase(userId, newToken);
      },
    );

    // Handle clicks when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Handle clicks when app is terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final url = message.data['url'];
    if (url != null) {
      final uri = Uri.tryParse(url.toString());
      if (uri != null) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }
}
