import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/failure/failure.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/profile/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.read(supabaseClientProvider)),
);

class ProfileRepository {
  final SupabaseClient supabaseClient;
  ProfileRepository(this.supabaseClient);

  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return right(UserProfile.fromJson(response));
    } catch (e) {
      return left(Failure("Couldn't load profile."));
    }
  }

  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile profile,
  ) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .update(profile.toJson())
          .eq('user_id', profile.userId)
          .select()
          .single();

      return right(UserProfile.fromJson(response));
    } catch (e) {
      return left(Failure("Couldn't update profile."));
    }
  }
}
