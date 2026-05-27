part of 'forget_psswrd_cubit.dart';

abstract class ForgotPasswordState {
  final bool isLoading;

  const ForgotPasswordState({this.isLoading = false});
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial({super.isLoading});
}

class OtpSent extends ForgotPasswordState {
  final String phone;

  const OtpSent({
    required this.phone,
    super.isLoading,
  });
}

class OtpVerified extends ForgotPasswordState {
  final String phone;

  const OtpVerified({
    required this.phone,
    super.isLoading,
  });
}

class PasswordResetSuccess extends ForgotPasswordState {}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;

  const ForgotPasswordError(
    this.message, {
    super.isLoading,
  });
}