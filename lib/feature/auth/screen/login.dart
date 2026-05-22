import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/core/theme/app_colors.dart';
import 'package:oxdo/core/theme/app_text_style.dart';
import 'package:oxdo/core/theme/asset_resources.dart';
import 'package:oxdo/feature/sidebar/main_screen.dart';
import 'package:oxdo/feature/staff_managment/designation/cubit/cubit/permission_cubit.dart';
import 'package:sizer/sizer.dart';

import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
      permissionCubit: context.read<PermissionCubit>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (_) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              _buildBackground(),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLoginCard(context, isLoading),
                      SizedBox(height: 1.h),
                      Text(
                        '© 2026. Crafted with ❤️ by Mictco It Solutions',
                        style: AppTextStyle.small(
                          color: Colors.grey,
                          size: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Background ──────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Column(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A4F7A), Color(0xFF1E3A5F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Expanded(child: Container(color: AppColors.background)),
      ],
    );
  }

  // ─── Card ────────────────────────────────────────────────────────────────

  Widget _buildLoginCard(BuildContext context, bool isLoading) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              // child: Column(
              //   children: [
              //     Text(
              //       'OXDO',
              //       style: AppTextStyle.heading(
              //         weight: FontWeight.bold,
              //         color: Colors.blue,
              //       ),
              //     ),
              //     Text(
              //       'Technology Pvt Ltd.',
              //       style: AppTextStyle.heading(color: Colors.grey, size: 14),
              //     ),
              //   ],
              // ),
              child: Image.asset(AssetResources.logo, width: 10.w),
            ),

            // const SizedBox(height: 30),

            // Username
            Text('Email', style: AppTextStyle.medium()),
            const SizedBox(height: 8),
            _buildUsernameField(),

            const SizedBox(height: 16),

            // Password
            Text('Password', style: AppTextStyle.medium()),
            SizedBox(height: 0.5.h),
            _buildPasswordField(),

            SizedBox(height: 1.5.h),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // TODO: implement forgot password
                },
                child: Text(
                  'Forgot password?',
                  style: AppTextStyle.medium(
                    size: 10.sp,
                    color: Colors.grey,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            SizedBox(height: 1.3.h),

            // Sign In button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _handleLogin(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF1ABC9C),
                  disabledBackgroundColor: const Color(
                    0xFF1ABC9C,
                  ).withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: AppTextStyle.medium(
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Fields ──────────────────────────────────────────────────────────────

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Enter email',
        hintStyle: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 4) {
          return 'Password is too short';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Enter password',
        hintStyle: AppTextStyle.medium(size: 11.sp, color: AppColors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// ─── Wave Clipper ─────────────────────────────────────────────────────────────

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 80)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 80,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
