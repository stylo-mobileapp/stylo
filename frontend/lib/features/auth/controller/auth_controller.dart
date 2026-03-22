import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/utils/show_error_dialog.dart';
import 'package:frontend/features/auth/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref.read(authRepositoryProvider), ref),
);

final authStateProvider = StreamProvider(
  (ref) => ref.read(authControllerProvider.notifier).authState,
);

class AuthController extends StateNotifier<bool> {
  final AuthRepository authRepository;
  final Ref ref;
  AuthController(this.authRepository, this.ref) : super(false);

  Stream<AuthState> get authState => authRepository.authState;

  Future<void> signInAsGuest({
    required BuildContext context,
    required String gender,
    required List<String> brands,
  }) async {
    state = true;
    final response = await authRepository.signInAsGuest(
      gender: gender,
      brands: brands,
    );
    state = false;
    response.fold((l) => showErrorDialog(context, l.message), (r) => null);
  }
}
