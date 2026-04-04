import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/failure/failure.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationsRepositoryProvider = Provider(
  (ref) => NotificationsRepository(ref.read(supabaseClientProvider)),
);

class NotificationsRepository {
  final SupabaseClient supabaseClient;
  NotificationsRepository(this.supabaseClient);

  Future<Either<Failure, List<NotificationModel>>> getNotifications(
    String userId,
  ) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      final notifications = (response as List).map((row) {
        return NotificationModel.fromJson(row as Map<String, dynamic>);
      }).toList();

      return right(notifications);
    } catch (e) {
      return left(Failure("Couldn't load notifications."));
    }
  }

  // Optional: Add markAsRead or delete notification methods if needed in the future
  Future<Either<Failure, void>> deleteNotification(String id) async {
    try {
      await supabaseClient.from('notifications').delete().eq('id', id);
      return right(null);
    } catch (e) {
      return left(Failure("Couldn't delete notification."));
    }
  }
}
