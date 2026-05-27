import 'package:oxdo/feature/auth/data/firebase_auth_service.dart';
import 'package:oxdo/core/shared_preference/session_service.dart';
import 'package:oxdo/feature/auth/cubit/auth/auth_cubit.dart';

class ServiceLocator {
  ServiceLocator._();
 
  static final _sessionService = SessionService();
  static final _authService = FirebaseAuthService();
 
  static AuthCubit get authCubit => AuthCubit(
        authService: _authService,
        sessionService: _sessionService,
      );
}