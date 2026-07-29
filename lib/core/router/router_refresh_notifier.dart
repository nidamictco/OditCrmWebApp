// lib/core/router/router_refresh_notifier.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../feature/auth/cubit/auth/auth_cubit.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  final AuthCubit authCubit;
  late final StreamSubscription<AuthState> _subscription;

  RouterRefreshNotifier(this.authCubit) {
    _subscription = authCubit.stream.listen((state) {
      // Only notify GoRouter when a navigation-relevant state change occurs.
      // AuthLoading and AuthError are transient states — the router's redirect
      // callback cannot meaningfully act on them (it returns null for both),
      // so notifying on them only causes the route tree to rebuild and momentarily
      // replace the current screen, which creates a duplicate widget instance
      // with a second live BlocConsumer subscription before the original is
      // disposed — resulting in every AuthError SnackBar appearing twice.
      if (state is Authenticated || state is AuthLoggedOut) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
