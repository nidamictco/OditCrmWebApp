
import 'package:Odit_CRM/core/theme/app_text_style.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/auth/auth_cubit.dart';
import 'login.dart';

import '../../mother_company/MotherCompanyMainScreen.dart';
import '../../sub_company/sidebar/main_screen.dart';
import '../../sub_company/staff_managment/designation/cubit/cubit/permission_cubit.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // ✅ Kick off session check with permissionCubit available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkSession(
        permissionCubit: context.read<PermissionCubit>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          if (state.message.toLowerCase().contains('suspended') ||
              state.message.toLowerCase().contains('upgrade plan')) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Account Suspended',
                        style: AppTextStyle.body(
                          fontWeight: FontWeight.bold,
                          color: AppThemeColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    state.message,
                    style: AppTextStyle.body(
                      color: AppThemeColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'OK',
                        style: AppTextStyle.body(
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is Authenticated) {
          return state.user.companyType == 'mother_company'
              ? const MotherCompanyMainScreen()
              : const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
