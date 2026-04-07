import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/core/utils/show_error_dialog.dart';
import 'package:frontend/features/profile/models/user_profile_model.dart';
import 'package:frontend/features/profile/repository/profile_repository.dart';

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.read(supabaseClientProvider).auth.currentUser;
  if (user == null) return null;
  final repository = ref.read(profileRepositoryProvider);
  final response = await repository.getUserProfile(user.id);
  return response.fold((l) => throw l.message, (r) => r);
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, bool>((ref) {
      return ProfileController(ref.read(profileRepositoryProvider), ref);
    });

class ProfileController extends StateNotifier<bool> {
  final ProfileRepository _profileRepository;
  final Ref _ref;

  ProfileController(this._profileRepository, this._ref) : super(false);

  Future<void> updateGender({
    required BuildContext context,
    required String gender,
  }) async {
    final currentProfile = _ref.read(userProfileProvider).value;
    if (currentProfile == null) return;

    state = true;
    final updatedProfile = currentProfile.copyWith(
      gender: gender,
      updatedAt: DateTime.now(),
    );

    final response = await _profileRepository.updateUserProfile(updatedProfile);
    state = false;

    response.fold(
      (l) => showErrorDialog(context, l.message),
      (r) => _ref.invalidate(userProfileProvider),
    );
  }

  Future<void> updateBrands({
    required BuildContext context,
    required List<String> brands,
  }) async {
    final currentProfile = _ref.read(userProfileProvider).value;
    if (currentProfile == null) return;

    state = true;
    final updatedProfile = currentProfile.copyWith(
      brands: brands,
      updatedAt: DateTime.now(),
    );

    final response = await _profileRepository.updateUserProfile(updatedProfile);
    state = false;

    response.fold(
      (l) => showErrorDialog(context, l.message),
      (r) => _ref.invalidate(userProfileProvider),
    );
  }
}
