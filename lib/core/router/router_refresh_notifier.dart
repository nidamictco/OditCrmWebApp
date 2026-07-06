// lib/core/router/router_refresh_notifier.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../feature/auth/cubit/auth/auth_cubit.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  final AuthCubit authCubit;
  late final StreamSubscription<AuthState> _subscription;

  RouterRefreshNotifier(this.authCubit) {
    _subscription = authCubit.stream.listen((state) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
