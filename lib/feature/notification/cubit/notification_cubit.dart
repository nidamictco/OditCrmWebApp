import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/utils/notification_service.dart';
import 'package:oxdo/feature/notification/cubit/notification_state.dart';
import 'package:oxdo/feature/notification/data/notification_repo.dart';
import 'package:oxdo/feature/notification/model/notification_model.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo _repo;
  StreamSubscription? _subscription;
  final Set<String> _seenIds = {};

  // keeps last known list so delete states can still show the UI
  List<NotificationModel> _currentList = [];

  NotificationCubit(this._repo) : super(NotificationInitial());

  void load(String staffId) {
    emit(NotificationLoading());
    _subscription?.cancel();

    _subscription = _repo.streamByStaff(staffId).listen(
      (notifications) async {
        _currentList = notifications;
        await _triggerLocalForNew(notifications);
        emit(NotificationLoaded(notifications));
      },
      onError: (e) {
      log('[NotificationCubit] load error: $e'); 
      if (isClosed) return;
      emit(NotificationError(e.toString()));
    },
    );
  }

  // delete a single notification
  Future<void> deleteOne(String notificationId) async {
    emit(NotificationDeleting(_currentList));
    try {
      _seenIds.remove(notificationId); // clean up seen tracker
      await _repo.deleteOne(notificationId);
      // stream will automatically emit updated list after deletion
    } catch (e) {
      emit(NotificationDeleteError(_currentList, e.toString()));
    }
  }

  // delete all notifications for current staff
  Future<void> deleteAll(String staffId) async {
    emit(NotificationDeleting(_currentList));
    try {
      _seenIds.clear(); // clear all seen trackers
      await _repo.deleteAll(staffId);
      // stream will automatically emit empty list after deletion
    } catch (e) {
      emit(NotificationDeleteError(_currentList, e.toString()));
    }
  }

  Future<void> _triggerLocalForNew(List<NotificationModel> notifications) async {
    final isFirstLoad = _seenIds.isEmpty;

    for (final n in notifications) {
      if (!_seenIds.contains(n.id)) {
        _seenIds.add(n.id);
        if (!isFirstLoad) {
          await NotificationService.show(
            title: n.title,
            body: n.message,
          );
        }
      }
    }
  }

  // in notification_cubit.dart
Future<void> markAllRead(String staffId) async {
  try {
    await _repo.markAllRead(staffId);
    // stream re-emits automatically with isRead: true → unreadCount drops to 0
  } catch (e) {
    log('[NotificationCubit] markAllRead error: $e');
  }
}

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}