import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  }
}
