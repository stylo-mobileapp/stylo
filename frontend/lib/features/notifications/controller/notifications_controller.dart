import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/repository/notifications_repository.dart';

final notificationsControllerProvider =
    StateNotifierProvider<
      NotificationsController,
      AsyncValue<List<NotificationModel>>
    >(
      (ref) => NotificationsController(
        ref.read(notificationsRepositoryProvider),
        ref,
      ),
    );

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationsRepository notificationsRepository;
  final Ref ref;

  NotificationsController(this.notificationsRepository, this.ref)
    : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final result = await notificationsRepository.getNotifications(userId);
      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (notifications) => state = AsyncValue.data(notifications),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
