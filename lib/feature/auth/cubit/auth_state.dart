part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated({required this.user});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class AuthLoggedOut extends AuthState {}