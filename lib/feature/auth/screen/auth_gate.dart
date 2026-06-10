// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:oxdo/core/theme/app_colors.dart';
// import 'package:oxdo/feature/auth/cubit/auth_cubit.dart';
// import 'package:oxdo/feature/auth/screen/login.dart';
// import 'package:oxdo/feature/sidebar/main_screen.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, state) {
//         if (state is AuthLoading || state is AuthInitial) {
//           log('log : state : $state');
//           return const Scaffold(
//             backgroundColor: AppColors.background,
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         log('log : state : $state'); 
//         if (state is Authenticated) {
//           return const MainScreen();
//         }
//         return const LoginScreen();
//       },
//     );
//   }
// }

// lib/feature/auth/screen/auth_gate.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/feature/auth/cubit/auth/auth_cubit.dart';
import 'package:oxdo/feature/auth/screen/login.dart';

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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        log('log : state : $state');
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is Authenticated) return const MainScreen();
        return const LoginScreen();
      },
    );
  }
}