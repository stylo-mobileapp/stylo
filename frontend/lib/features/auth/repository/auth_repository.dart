import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/failure/failure.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.read(supabaseClientProvider)),
);

class AuthRepository {
  final SupabaseClient supabaseClient;
  AuthRepository(this.supabaseClient);

  Stream<AuthState> get authState => supabaseClient.auth.onAuthStateChange;

  Future<Either<Failure, void>> signInAsGuest({
    required String gender,
    required List<String> brands,
  }) async {
    try {
      final response = await supabaseClient.auth.signInAnonymously(
        data: {'gender': gender, 'brands': brands},
      );

      if (response.user == null) {
        throw "User is null.";
      } else {
        return right(null);
      }
    } catch (e) {
      return left(Failure("Couldn’t sign you in."));
    }
  }
}
